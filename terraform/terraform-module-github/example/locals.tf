locals {
  aws_region  = "eu-west-1"
  environment = "example"
  application = "example"
  default_tags = {
    Environment = local.environment
    Application = local.application
    Terraform   = true
    Contact     = "support@example.com"
  }
}
