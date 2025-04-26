terraform {
  required_version = ">= 1.5.0"

  cloud {
    organization = "The-Plug"

    workspaces {
      // TEST COMMENT TO TRIGGER ACTIONS WORKFLOW - REMOVE LATER!
      name = "The-Plug-Workspace-GitHub-Actions"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}