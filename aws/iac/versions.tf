terraform {
  required_version = ">= 1.5.0"

  cloud {
    organization = "The-Plug"

    workspaces {
      name = "The-Plug-Workspace"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}