#Remote State variables
variable "network_remote_state_key" {
  default = "networking.state"
}

variable "network_remote_state_bucket" {}

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "region" {
  default = "us-east-1"
}

#Web front end variables
variable "key_name" {}

variable "ip_range" {
  default = "0.0.0.0/0"
}

variable "rds_username" {
  default     = "ddtuser"
  description = "User name"
}

variable "rds_password" {
  default     = "TerraformIsNumber1!"
  description = "password, provide through your ENV variables"
}

variable "projectcode" {
  default = "8675309"
}

variable "tablename" {}

variable "url" {}
