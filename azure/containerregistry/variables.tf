variable "location" {
  description = "Specifies the supported Azure location where the resource exists."
  type        = string
}

variable "name" {
  description = "Specifies the name of the Databricks Workspace"
  type        = string
}


variable "resource_group_name" {
  description = "The name of the resource group in which to create"
  type        = string
}

variable "sku" {
  description = "The sku to use for the Databricks Workspace. Possible values are standard, premium, or trial."
  type        = string
  default     = "Premium"
}

variable "tags" {
  description = "A map of tags to add"
  type        = map(string)
}
