terraform {
  required_version = ">= 1.6.6"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.52.0" # Cambia a la última versión disponible
    }
  }
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key # API Key de IBM Cloud
  region           = "eu-gb"          # Región inicial
}

resource "ibm_is_vpc" "vpc" {
  name           = "vpc-vsanchez"
  resource_group = var.rg-name
}