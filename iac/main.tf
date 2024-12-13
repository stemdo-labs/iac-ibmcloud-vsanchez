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

# Crear VPC para "vpc-bd"
resource "ibm_is_vpc" "vpc_bd" {
  name           = "vpc-bd-vsanchez"
  resource_group = var.rg-name
}

# Crear VPC para "vpc-cluster"
resource "ibm_is_vpc" "vpc_cluster" {
  name           = "vpc-cluster-vsanchez"
  resource_group = var.rg-name
}

# Crear Subnet para "vpc-bd" en Londres
resource "ibm_is_subnet" "subnet_bd" {
  name            = "subnet-bd-vsanchez"
  vpc             = ibm_is_vpc.vpc_bd.id
  zone            = "eu-gb-1" # Zona de Londres
  ipv4_cidr_block = "10.242.1.0/18" # Cambia por el rango CIDR que necesites
  resource_group  = var.rg-name
}

# Crear Subnet para "vpc-cluster" en Londres
resource "ibm_is_subnet" "subnet_cluster" {
  name            = "subnet-cluster-vsanchez"
  vpc             = ibm_is_vpc.vpc_cluster.id
  zone            = "eu-gb-2" # Otra zona de Londres
  ipv4_cidr_block = "10.242.2.0/18" # Cambia por el rango CIDR que necesites
  resource_group  = var.rg-name
}


