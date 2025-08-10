variable "project" {
  description = "Project name prefix for resource group."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stage, prod, etc.)."
  type        = string
}

variable "type" {
  description = "Type or workload for the resource group (e.g., network, compute, shared)."
  type        = string
}

variable "location" {
  description = "Azure region for the resource group."
  type        = string
}
