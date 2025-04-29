variable "client_id" {
  type        = string
  description = "The Client ID of the Service Principal"
}

variable "client_secret" {
  type        = string
  description = "The Client Secret of the Service Principal"
}

variable "subscription_id" {
  type        = string
  description = "The Subscription ID to deploy the resources into"
}

variable "tenant_id" {
  type        = string
  description = "The Tenant ID of the Service Principal"
}
