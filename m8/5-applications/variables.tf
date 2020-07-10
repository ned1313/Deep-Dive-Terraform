#Remove State variables
variable "network_remote_state_key" {
  default = "networking.state"
}

variable "network_remote_state_bucket" {}

variable "region" {
  default = "us-east-1"
}

variable "aws_profile" {}

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
  default = "TerraformIsNumber1!"
  description = "password, provide through your ENV variables"
}

variable "projectcode" {
  default = "8675309"
}

variable "tablename" {}

variable "url" {}

variable "playbook_repository" {}
