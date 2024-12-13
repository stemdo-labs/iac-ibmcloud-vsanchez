terraform {
  required_version = ">=1.0.0, <2.0"
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
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
  ipv4_cidr_block = "10.242.0.0/24" # Cambia por el rango CIDR que necesites
  resource_group  = var.rg-name
}

# Crear Subnet para "vpc-cluster" en Londres
resource "ibm_is_subnet" "subnet_cluster" {
  name            = "subnet-cluster-vsanchez"
  vpc             = ibm_is_vpc.vpc_cluster.id
  zone            = "eu-gb-2" # Otra zona de Londres
  ipv4_cidr_block = "10.242.64.0/24" # Cambia por el rango CIDR que necesites
  resource_group  = var.rg-name
}

resource "ibm_is_virtual_network_interface" "vni_vsanchezbd" {
    name                                    = "vni-vsanchez1"
    allow_ip_spoofing               = false
    enable_infrastructure_nat   = true
    primary_ip {
        auto_delete       = false
    address             = "10.242.0.8"
    }
    subnet   = ibm_is_subnet.subnet_bd.id
}

resource "ibm_is_virtual_network_interface" "vni_vsanchezcluster" {
    name                                    = "vni-vsanchez2"
    allow_ip_spoofing               = false
    enable_infrastructure_nat   = true
    primary_ip {
        auto_delete       = false
    address             = "10.242.64.8"
    }
    subnet   = ibm_is_subnet.subnet_cluster.id
}


