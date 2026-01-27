output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.reverse_proxy.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.reverse_proxy.arn
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.reverse_proxy.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.reverse_proxy.arn
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "nat_gateway_public_ips" {
  description = "List of public IPs of the NAT Gateways"
  value       = module.vpc.nat_public_ips
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.reverse_proxy.id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.reverse_proxy.name
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.reverse_proxy.id
}

output "logs_bucket_id" {
  description = "ID of the S3 bucket for logs"
  value       = aws_s3_bucket.logs.id
}
