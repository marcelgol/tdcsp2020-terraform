# Use the Azure Resource Manager Provider
provider "azurerm" {
  features {
  }
}

# Create a new Resource Group
resource "azurerm_resource_group" "group" {
  name     = "tdcsp2020-demo"
  location = "brazilsouth"
}

# Create an App Service Plan with Linux
resource "azurerm_app_service_plan" "appserviceplan" {
  name                = "${azurerm_resource_group.group.name}-plan"
  location            = "${azurerm_resource_group.group.location}"
  resource_group_name = "${azurerm_resource_group.group.name}"

  # Define Linux as Host OS
  kind = "Linux"
  reserved = true

  # Choose size
  sku {
    tier = "Basic"
    size = "B1"
  }

#   properties {
#     reserved = true # Mandatory for Linux plans
#   }
}

# Create an Azure Web App for Containers in that App Service Plan
resource "azurerm_app_service" "dockerapp" {
  name                = "${azurerm_resource_group.group.name}-dockerapp"
  location            = "${azurerm_resource_group.group.location}"
  resource_group_name = "${azurerm_resource_group.group.name}"
  app_service_plan_id = "${azurerm_app_service_plan.appserviceplan.id}"

  # Do not attach Storage by default
  app_settings =  {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false


    # Settings for private Container Registires  
    DOCKER_REGISTRY_SERVER_URL      = "tdcsp2020.azurecr.io"
    DOCKER_REGISTRY_SERVER_USERNAME = "tdcsp2020"
    DOCKER_REGISTRY_SERVER_PASSWORD = "Y32jBe4IoVAqZh/1JjwX7ljPIHBpCw5u"

  }

  # Configure Docker Image to load on start
  site_config {
    linux_fx_version = "DOCKER|tdcsp2020.azurecr.io/marcelgoltdcsp:latest"
    always_on        = "true"
  }

  identity {
    type = "SystemAssigned"
  }
}