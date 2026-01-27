terraform {
  required_version = ">= 1.5.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Get ACM certificate
data "aws_acm_certificate" "cert" {
  domain   = var.certificate_domain
  statuses = ["ISSUED"]
}

module "reverse_proxy" {
  source = "../../"

  name_prefix              = var.name_prefix
  environment              = var.environment
  vpc_cidr                 = var.vpc_cidr
  instance_type            = var.instance_type
  key_name                 = var.key_name
  ssm_instance_profile_name = var.ssm_instance_profile_name

  certificate_arn = data.aws_acm_certificate.cert.arn
  backend_url     = var.backend_url

  reverse_proxy_rules = var.reverse_proxy_rules

  # Optional: Enable Promtail
  enable_promtail = var.enable_promtail
  loki_host       = var.loki_host
  loki_domain     = var.loki_domain

  # Optional: Associate WAF
  waf_web_acl_arn = var.waf_web_acl_arn

  tags = var.tags
}
