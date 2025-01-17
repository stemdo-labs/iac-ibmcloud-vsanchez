variable "ibmcloud_api_key" {
  description = "API Key para IBM Cloud"
  type        = string
  sensitive   = true
}

variable "rg-name" {
  description = "Nombre del grupo de recursos"
  type        = string
  sensitive = true

  
}

variable "ssh_key" {
  description = "Clave SSH para la VM"
  type        = string
  sensitive   = true
  
}
variable "id_imagen" {
  description = "ID de la imagen"
  type        = string
  sensitive = true
}

variable "public_ssh_key" {
  description = "Clave SSH para la VM"
  type        = string
}
variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
  sensitive = true
  
}