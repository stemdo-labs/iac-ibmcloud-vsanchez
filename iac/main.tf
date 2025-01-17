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
  region           = "eu-es"          # Región inicial
  
}
 # acr
resource "ibm_cr_namespace" "rg_namespace" {
  name              = "cr-vsanchez"
  resource_group_id = var.rg-name
}


# Crear Subnet para "vpc-bd" en Londres
resource "ibm_is_subnet" "subnet_bd" {
  name            = "subnet-bd-vsanchez"
  vpc             = var.vpc_id
  zone            = "eu-es-1" 
  ipv4_cidr_block = "10.251.10.0/24" 
  resource_group  = var.rg-name
  

}

resource "ibm_is_security_group" "security_group-vsanchez" {
  name = "security-group-vsanchez"
  resource_group = var.rg-name
  vpc = var.vpc_id
  
}

# Crear una regla para habilitar el puerto 22 (SSH)
resource "ibm_is_security_group_rule" "allow_ssh" {
  direction      = "inbound"
  remote         = "0.0.0.0/0" 
  ip_version     = "ipv4"
  group =  ibm_is_security_group.security_group-vsanchez.id
  tcp {
  port_min       = 22
  port_max       = 22
  }

  
}
resource "ibm_is_security_group_rule" "allow_postgres" {
  direction      = "inbound"
  remote         = "0.0.0.0/0" 
  ip_version     = "ipv4"
  group =  ibm_is_security_group.security_group-vsanchez.id
  tcp {
  port_min       = 5432
  port_max       = 5432
  }

  
}
resource "ibm_is_security_group_rule" "allow_ping" {
  direction      = "inbound"
  remote         = "0.0.0.0/0" 
  ip_version     = "ipv4"
  group =  ibm_is_security_group.security_group-vsanchez.id
  icmp {
    type = 8
    code = 0
  }

  
}
 
resource "ibm_is_security_group_rule" "allow_outbound" {
  direction      = "outbound"
  remote         = "0.0.0.0/0" 
  ip_version     = "ipv4"
  group =  ibm_is_security_group.security_group-vsanchez.id
}

resource "ibm_is_ssh_key" "ssh_key" {
  name       = "ssh-key-vsanchez"
  public_key = var.public_ssh_key
  type       = "rsa"
  resource_group = var.rg-name
}

resource "ibm_is_instance" "instance_vsanchez" {
  name                      = "vm-bd-vsanchez"
  image                     = var.id_imagen
  profile                   = "bx2-2x8"
  vpc = var.vpc_id
  zone =  "eu-es-1"
  resource_group = var.rg-name
  keys = [ ibm_is_ssh_key.ssh_key.id ]

  primary_network_interface {
    subnet = ibm_is_subnet.subnet_bd.id
    allow_ip_spoofing = true
    security_groups  = [ ibm_is_security_group.security_group-vsanchez.id ]
    primary_ip {
    auto_delete       = false
    address             = "10.251.10.34"
    }
    
  }
}



resource "ibm_resource_instance" "cos_instance" {
  resource_group_id = var.rg-name
  name     = "cos-instance-vsanchez"
  service  = "cloud-object-storage"
  plan     = "standard"
  location = "global"
}






 # Contenedor para los backups
#  resource "ibm_resource_instance" "backups-instance-vsanchez" {
#    name              = "backups-instance-vsanchez"
#    resource_group_id = var.rg-name
#    service           = "cloud-object-storage"
#    plan              = "standard"
#    location          = "eu-gb"
#  }

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
