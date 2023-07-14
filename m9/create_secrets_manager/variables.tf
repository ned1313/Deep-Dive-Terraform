variable "region" {
  type        = string
  description = "(Optional) AWS Region to deploy in. Defaults to us-east-1."
  default     = "us-east-1"
}

variable "api_key" {
  type        = string
  description = "(Required) String to use for API key"
  sensitive   = true
}