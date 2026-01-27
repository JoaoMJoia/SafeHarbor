# Reverse Proxy Infrastructure as Code Example
#
# This file demonstrates how to use the reverse-proxy module to deploy
# a highly available reverse proxy infrastructure on AWS using Apache HTTP Server.
#
# Prerequisites:
#   - AWS CLI configured with appropriate credentials
#   - An existing ACM certificate in the target region
#   - An existing AWS key pair for EC2 instances
#   - An existing IAM instance profile with SSM permissions
#   - (Optional) An existing WAF Web ACL for additional security

# ============================================================================
# Backend Configuration
# ============================================================================
# Store Terraform state in a remote S3 bucket with state locking via DynamoDB
#
# Note: This should typically be in a separate backend.tf file, but is shown
# here for completeness. Uncomment and configure for your environment.
#
# terraform {
#   backend "s3" {
#     bucket         = "my-org-tfstate-aws"
#     key            = "reverse-proxy/terraform.tfstate"
#     region         = "eu-west-1"
#     dynamodb_table = "terraform-state-locks-aws"
#     encrypt        = true
#   }
# }

# ============================================================================
# Provider Configuration
# ============================================================================
# Configure the AWS provider
#
# Note: This should typically be in a separate providers.tf file, but is shown
# here for completeness. Uncomment and configure for your environment.
#
# provider "aws" {
#   region = "eu-west-1"
#   
#   default_tags {
#     tags = {
#       ManagedBy   = "Terraform"
#       Project     = "ReverseProxy"
#       Environment = "production"
#     }
#   }
# }

# ============================================================================
# Data Sources
# ============================================================================
# Get existing AWS resources that are required by the module

# Get ACM certificate for HTTPS termination
# The certificate must exist in the same region as the ALB
data "aws_acm_certificate" "main" {
  domain   = "*.example.com"
  statuses = ["ISSUED"]
  
  # Alternative: Use certificate ARN directly
  # most_recent = true
  # provider    = aws.us-east-1  # For CloudFront, use us-east-1
}

# Get current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ============================================================================
# Reverse Proxy Module Example
# ============================================================================
# Simple example of deploying a reverse proxy infrastructure

module "reverse_proxy" {
  # Using local module (for development/testing)
  source = "./modules/reverse-proxy"
  
  # Or use from git repository (for production)
  # source = "git::https://github.com/my-org/terraform-module-reverse-proxy.git?ref=v1.0.0"

  name_prefix              = "my-app"
  environment              = "prod"
  vpc_cidr                 = "10.0.0.0/16"
  instance_type            = "t3.medium"
  key_name                 = "my-key-pair"
  ssm_instance_profile_name = "my-ssm-instance-profile"
  
  # Certificate and backend configuration
  certificate_arn = data.aws_acm_certificate.main.arn
  backend_url     = "https://backend.example.com"
  
  # Reverse proxy rules
  # Define how requests should be routed to backend services
  reverse_proxy_rules = [
    {
      path     = "/app"
      backend  = "https://backend.example.com/app"
      preserve = true
    },
    {
      path     = "/"
      backend  = "https://backend.example.com/"
      preserve = true
    }
  ]
  
  # Optional: Enable Promtail for log shipping to Loki
  # enable_promtail = true
  # loki_host       = "loki"
  # loki_domain     = "monitoring.example.com"
  
  # Optional: Associate WAF Web ACL for additional security
  # waf_web_acl_arn = "arn:aws:wafv2:eu-west-1:123456789012:global/webacl/prod-waf/abc123"
  
  tags = {
    Environment = "production"
    Project     = "my-app"
    Team        = "platform"
  }
}

# ============================================================================
# Outputs
# ============================================================================
# Output important values for use in other configurations or scripts

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.reverse_proxy.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB (for Route53 alias records)"
  value       = module.reverse_proxy.alb_zone_id
}

output "nat_gateway_public_ips" {
  description = "Public IPs of the NAT Gateways (for whitelisting)"
  value       = module.reverse_proxy.nat_gateway_public_ips
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.reverse_proxy.vpc_id
}
