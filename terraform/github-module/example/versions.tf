terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    github = {
      source  = "integrations/github"
      version = ">= 5.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = ">= 1.0.0"
    }
  }
  required_version = ">= 1.9.7"
}
