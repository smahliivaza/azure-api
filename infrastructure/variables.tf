variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment (dev / test / stage / prod)"
}

variable "location" {
  type        = string
  description = "Azure region to deploy module to"
}

variable "failover_location" {
  type        = string
  description = "Another Azure region to cover failover scenario"
}

variable "resource_group" {
  type        = string
  description = "Pre-configured resource group on Azure"
}

variable "storage_account" {
  type        = string
  description = "Pre-configured storage account on Azure"
}
