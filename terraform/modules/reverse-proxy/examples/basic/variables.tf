variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "reverse-proxy"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Name of the AWS key pair"
  type        = string
}

variable "ssm_instance_profile_name" {
  description = "Name of the IAM instance profile for SSM"
  type        = string
}

variable "certificate_domain" {
  description = "Domain name for the ACM certificate"
  type        = string
}

variable "backend_url" {
  description = "Backend URL to proxy requests to"
  type        = string
}

variable "reverse_proxy_rules" {
  description = "List of reverse proxy rules"
  type = list(object({
    path     = string
    backend  = string
    preserve = optional(bool, true)
  }))
  default = [
    {
      path     = "/"
      backend  = "https://example.com/"
      preserve = true
    }
  ]
}

variable "enable_promtail" {
  description = "Enable Promtail for log shipping"
  type        = bool
  default     = false
}

variable "loki_host" {
  description = "Loki hostname"
  type        = string
  default     = ""
}

variable "loki_domain" {
  description = "Loki domain"
  type        = string
  default     = ""
}

variable "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
