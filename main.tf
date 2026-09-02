terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform-cicd-lab-v2"
  location = "west Europe"
}

resource "azurerm_service_plan" "plan" {
  name                = "asp-terraform-lab"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "webapp" {
  name                = "app-tf-lab-${random_integer.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.plan.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    always_on = false
    application_stack {
      node_version = "18-lts"
    }
  }
}

resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

output "webapp_name" {
  value       = azurerm_linux_web_app.webapp.name
  description = "The name of the generated Azure Web App"
}

# Import Resource Group
import {
  to = azurerm_resource_group.rg
  id = "/subscriptions/1f732aca-0422-4a0c-8e68-9db55f9accb2/resourceGroups/rg-terraform-cicd-lab-v2"
}

# Import App Service Plan
import {
  to = azurerm_service_plan.plan
  id = "/subscriptions/1f732aca-0422-4a0c-8e68-9db55f9accb2/resourceGroups/rg-terraform-cicd-lab-v2/providers/Microsoft.Web/serverFarms/asp-terraform-lab"
}

# Import Linux Web App
import {
  to = azurerm_linux_web_app.webapp
  id = "/subscriptions/1f732aca-0422-4a0c-8e68-9db55f9accb2/resourceGroups/rg-terraform-cicd-lab-v2/providers/Microsoft.Web/sites/app-tf-lab-${random_integer.suffix.result}"
}