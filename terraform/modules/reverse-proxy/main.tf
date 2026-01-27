# VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.13"

  name = "${var.name_prefix}-${var.environment}"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, var.availability_zone_count)
  private_subnets = [for i in range(var.availability_zone_count) : cidrsubnet(var.vpc_cidr, 8, i)]
  public_subnets  = [for i in range(var.availability_zone_count) : cidrsubnet(var.vpc_cidr, 8, i + 100)]

  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_dns_hostnames = true

  tags = var.tags
}

# Security Group
resource "aws_security_group" "reverse_proxy" {
  name        = "${var.name_prefix}-${var.environment}"
  description = "Security group for reverse proxy instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow HTTP traffic from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS traffic from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-${var.environment}"
    }
  )
  #checkov:skip=CKV_AWS_260: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 80"
  #checkov:skip=CKV_AWS_382: "Ensure no security groups allow egress from 0.0.0.0:0 to port -1"
}

# SSM IAM Instance Profile
data "aws_iam_instance_profile" "ssm_role" {
  name = var.ssm_instance_profile_name
}

# Launch template
resource "aws_launch_template" "reverse_proxy" {
  name_prefix   = "${var.name_prefix}-${var.environment}-"
  image_id      = data.aws_ami.amazon_linux_x86_64.id
  instance_type = var.instance_type
  key_name      = var.key_name

  # Attach the SSM IAM instance profile
  iam_instance_profile {
    name = data.aws_iam_instance_profile.ssm_role.name
  }

  network_interfaces {
    security_groups             = [aws_security_group.reverse_proxy.id]
    associate_public_ip_address = false
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Set environment variables
    BACKEND_URL="${var.backend_url}"
    LOG_NAME="${var.log_name}"
    LOKI_HOST="${var.loki_host}"
    LOKI_DOMAIN="${var.loki_domain}"
    ENABLE_PROMTAIL="${var.enable_promtail}"
    
    echo "Setting environment variables..."
    echo "BACKEND_URL=$BACKEND_URL" | sudo tee -a /etc/environment
    echo "LOG_NAME=$LOG_NAME" | sudo tee -a /etc/environment
    echo "LOKI_HOST=$LOKI_HOST" | sudo tee -a /etc/environment
    echo "LOKI_DOMAIN=$LOKI_DOMAIN" | sudo tee -a /etc/environment
    echo "ENABLE_PROMTAIL=$ENABLE_PROMTAIL" | sudo tee -a /etc/environment
    
    # Export variables for current session
    export BACKEND_URL
    export LOG_NAME
    export LOKI_HOST
    export LOKI_DOMAIN
    export ENABLE_PROMTAIL
    
    # Run the setup script
    ${file("${path.module}/setup.sh")}
    EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name = "${var.name_prefix}-${var.environment}-instance"
      }
    )
  }

  tags = var.tags
}

# Set aws_launch_template default_version to latest version
resource "null_resource" "set_default_version" {
  provisioner "local-exec" {
    command = <<EOT
    aws ec2 modify-launch-template --launch-template-id ${aws_launch_template.reverse_proxy.id} --default-version $(
        aws ec2 describe-launch-templates --launch-template-ids ${aws_launch_template.reverse_proxy.id} --query 'LaunchTemplates[0].LatestVersionNumber' --output text
    )
    EOT
  }

  depends_on = [aws_launch_template.reverse_proxy]
}

# Auto Scaling Group
resource "aws_autoscaling_group" "reverse_proxy" {
  name                = "${var.name_prefix}-${var.environment}"
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = module.vpc.private_subnets

  launch_template {
    id      = aws_launch_template.reverse_proxy.id
    version = aws_launch_template.reverse_proxy.latest_version
  }

  health_check_type         = "ELB"
  health_check_grace_period = var.health_check_grace_period

  target_group_arns = [aws_lb_target_group.reverse_proxy.arn]

  instance_maintenance_policy {
    max_healthy_percentage = 110
    min_healthy_percentage = 100
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-${var.environment}-instance"
    propagate_at_launch = true
  }

  # Force instance refresh when launch template changes
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = var.instance_refresh_min_healthy_percentage
      instance_warmup        = var.instance_refresh_warmup
    }
    triggers = ["launch_template"]
  }

  # Add a tag with launch template version to force refresh
  tag {
    key                 = "LaunchTemplateVersion"
    value               = aws_launch_template.reverse_proxy.latest_version
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }

  tags = var.tags
}

# Auto Scaling Policies
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.name_prefix}-${var.environment}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.reverse_proxy.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.name_prefix}-${var.environment}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.reverse_proxy.name
}

# Application Load Balancer (ALB)
resource "aws_lb" "reverse_proxy" {
  name                       = "${var.name_prefix}-${var.environment}"
  internal                   = false
  load_balancer_type         = "application"
  security_groups             = [aws_security_group.reverse_proxy.id]
  subnets                     = module.vpc.public_subnets
  enable_deletion_protection  = var.enable_deletion_protection
  idle_timeout               = var.idle_timeout
  preserve_host_header       = false
  xff_header_processing_mode  = "append"

  access_logs {
    bucket  = aws_s3_bucket.logs.id
    prefix  = "alb-logs"
    enabled = var.enable_alb_access_logs
  }

  depends_on = [
    aws_s3_bucket_policy.logs_bucket_policy,
    aws_s3_bucket.logs,
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-${var.environment}"
    }
  )
  #checkov:skip=CKV_AWS_131: "Ensure that ALB drops HTTP headers"
  #checkov:skip=CKV2_AWS_76: "Ensure AWS ALB attached WAFv2 WebACL is configured with AMR for Log4j Vulnerability"
}

# WAF association for the reverse proxy ALB (optional)
resource "aws_wafv2_web_acl_association" "waf" {
  count = var.waf_web_acl_arn != null ? 1 : 0

  resource_arn = aws_lb.reverse_proxy.arn
  web_acl_arn  = var.waf_web_acl_arn
}

# Target Group for the ALB
resource "aws_lb_target_group" "reverse_proxy" {
  name        = "${var.name_prefix}-${var.environment}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    protocol            = "HTTP"
    path                = var.health_check_path
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    matcher             = var.health_check_matcher
    port                = "traffic-port"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-${var.environment}-tg"
    }
  )
  #checkov:skip=CKV_AWS_378: "Ensure AWS Load Balancer doesn't use HTTP protocol"
}

# ALB Listeners
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.reverse_proxy.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      host        = "#{host}"
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.reverse_proxy.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.reverse_proxy.arn
  }
}

# S3 bucket for ALB access logs
resource "aws_s3_bucket" "logs" {
  bucket = "${var.name_prefix}-${var.environment}-logs"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-${var.environment}-logs"
    }
  )
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "expire-logs"
    status = "Enabled"
    expiration {
      days = var.log_retention_days
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

# S3 bucket policy to allow ALB to write logs
resource "aws_s3_bucket_policy" "logs_bucket_policy" {
  bucket = aws_s3_bucket.logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowALBLogging"
        Effect = "Allow"
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.logs.arn}/alb-logs/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      }
    ]
  })
}
