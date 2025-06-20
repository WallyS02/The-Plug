variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = "polandcentral"
}

variable "aks_name" {
  description = "AKS name"
  type        = string
  default     = "the-plug"
}

variable "dns_prefix" {
  description = "AKS API server DNS prefix"
  type        = string
  default     = "aks"
}

variable "agent_count" {
  description = "Node number in Node Pool"
  type        = number
  default     = 2
}

variable "agent_vm_size" {
  description = "VM size for nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "vnet_subnet_id" {
  description = "VNet subnet ID, where AKS nodes will be placed"
  type        = string
}

variable "service_cidr" {
  description = "Kubernetes services CIDR"
  type        = string
  default     = "10.1.0.0/16"
}

variable "dns_service_ip" {
  description = "Kubernetes DNS IP"
  type        = string
  default     = "10.1.0.10"
}

variable "acr_id" {
  description = "ACR ID"
  type        = string
}

variable "tags" {
  description = "Resource tag map"
  type        = map(string)
  default     = {}
}