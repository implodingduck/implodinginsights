
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.62.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=3.1.0"
    }
  }
  backend "azurerm" {

  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

locals {
  func_name = "impifun${random_string.unique.result}"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "rg-imploding-insights"
  location = var.location
}

resource "random_string" "unique" {
  length  = 8
  special = false
  upper   = false
}


module "functions" {
    source = "github.com/implodingduck/tfmodules//functionapp"
    func_name = "${local.func_name}"
    resource_group_name = azurerm_resource_group.rg.name
    resource_group_location = azurerm_resource_group.rg.location
    working_dir = "../functions"
    app_settings = {
      "FUNCTIONS_WORKER_RUNTIME" = "python"
    }

}

resource "null_resource" "build_linklist_react"{
  triggers = {
    #index = "2021-05-14T23:23:09Z"
    index = "${timestamp()}"
  }
  provisioner "local-exec" {
    working_dir = "../ui"
    command     = "npm run build"
  }
}