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

resource "ibm_is_instance" "instance_vsanchez" {
  name                      = "vm-bd-vsanchez"
  image                     = var.id_imagen
  profile                   = "bx2-2x8"
  vpc =  ibm_is_vpc.vpc_bd.id
  zone =  "eu-gb-1"
  resource_group = var.rg-name

  primary_network_interface {
    subnet = ibm_is_subnet.subnet_bd.id
    allow_ip_spoofing = true
    primary_ip {
    auto_delete       = false
    address             = "10.242.0.8"
    }
    
  }
}

resource "ibm_is_floating_ip" "public_ip" {
  name            = "public-ip-vm-bd-vsanchez"
  resource_group  = var.rg-name
  target          = ibm_is_instance.instance_vsanchez.primary_network_interface.0.id

}


 # acr
resource "ibm_cr_namespace" "rg_namespace" {
  name              = "cr-vsanchez"
  resource_group_id = var.rg-name
}


# # Contenedor para los backups
# resource "ibm_resource_instance" "backups-instance-vsanchez" {
#   name              = "backups-instance-vsanchez"
#   resource_group_id = var.rg-name
#   service           = "cloud-object-storage"
#   plan              = "standard"
#   location          = "eu-gb"
# }

# resource "ibm_cos_bucket" "backups" {
#   bucket_name = "backups"
#   storage_class = "standard" # Cambia el nivel de almacenamiento si es necesario
#   resource_instance_id =  ibm_resource_instance.backups-instance-vsanchez.id
# }

# data "ibm_iam_access_group" "public_access_group" {
#   access_group_name = "Public Access"  
# }

# resource "ibm_iam_access_group_policy" "public_access_group_policy" {
#   access_group_id = data.ibm_iam_access_group.public_access_group.id
#   roles           = ["Content Reader", "Content Writer"]

#   resources {
#     resource = ibm_cos_bucket.backups.bucket_name
#     resource_instance_id = ibm_cos_bucket.backups.id
#     resource_type = "bucket"
#     service = "cloud-object-storage"
#   }
# }
