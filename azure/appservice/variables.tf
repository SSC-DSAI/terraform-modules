
variable "acr_name" {
  description = "Specifies the name of the Container Registry"
  type = string
}

variable "app_service_name" {
  description = "The name which should be used for this App Service."
  type = string
}

variable "application_insights_name" {
  description = "The name which should be used for this Application Insights"
  type = string
}

variable "application_type" {
  description = "Specifies the type of Application Insights to create. Valid values are ios for iOS, java for Java web, MobileCenter for App Center, Node.JS for Node.js, other for General, phone for Windows Phone, store for Windows Store and web for ASP.NET. Please note these values are case sensitive; unmatched values are treated as ASP.NET by Azure. Changing this forces a new resource to be created."
  type = string
  default = "other"
}

variable "location" {
  description = "The Azure Region where the Service Plan should exist."
  type = string
}

variable "kind" {
  description = "The kind of the App Service Plan to create. Possible values are Windows (also available as App), Linux, elastic (for Premium Consumption) and FunctionApp (for a Consumption Plan). Defaults to Windows."
	type = string
	default = "Linux"
}

variable "resource_group_name" {
	description = "The name of the Resource Group where the AppService should exist."
	type = string
}

variable "service_plan_name" {
  description = "The name which should be used for this Service Plan."
  type = string
}

variable "tags" {
  description = "A map of tags to add"
  type        = map(string)
}
