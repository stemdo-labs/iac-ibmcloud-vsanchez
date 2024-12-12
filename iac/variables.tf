variable "ibmcloud_api_key" {
  description = "API Key para IBM Cloud"
  type        = string
  sensitive   = true
}

variable "rg-name" {
  description = "Nombre del grupo de recursos"
  type        = string
  default     = "Stemdo_Sandbox"
  
}