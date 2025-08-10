terraform{
    backend "azurerm"{ 
        resource_group_name = "rg-tfstate"
        storage_account_name = "tfstate1072"
        container_name = "tfstate"
        key = "terraform-dev.tfstate"   
    }
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = ">=3.0"
        }
    }
}