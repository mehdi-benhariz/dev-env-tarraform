variable "host_os" {
  type = string
  description = "value of the host OS"
}

variable "ssh_file" {
  type = string
  description = "path to the ssh key file"
}

variable "env" {
  type = string
  description = "environment"
  default = "Dev"
}

variable "rg-location" {
  type = string
  description = "location of the resource group"
  default = "East US"
}

variable "admin-user" {
  type = string
  description = "admin username for VM"
  default = "admin"
  
}
variable "azure_sbuscription_id" {
  type = string
  description = "Azure subscription ID"
  
}