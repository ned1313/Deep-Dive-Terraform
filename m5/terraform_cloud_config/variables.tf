variable "hostname" {
  type        = string
  description = "The Terraform Cloud/Enterprise hostname to connect to"
  default     = "app.terraform.io"
}

variable "oauth_name" {
  type    = string
  default = "tdd-github"
}

variable "organization" {
  type        = string
  description = "Terraform Cloud organization"
}

variable "gh_pat" {
  type        = string
  description = "Github Personal Access token"
}