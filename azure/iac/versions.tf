terraform {
  required_version = ">= 1.5.0"

  cloud {
    organization = "The-Plug"

    workspaces {
      name = "The-Plug-Workspace-Azure"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}