terraform {
  required_version = ">= 1.5.2"
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 5.0"
    }
  }
}