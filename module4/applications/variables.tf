#Remove State variables
variable "network_remote_state_key" {
  default = "networking.state"
}

variable "network_remote_state_bucket" {
  default = "ddt-networking"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}

#Web front end variables
variable "key_name" {
  default = "PluralsightKeys"
}

variable "ip_range" {
  default = "0.0.0.0/0"
}

variable "rds_username" {
  default     = "ddtuser"
  description = "User name"
}

variable "rds_password" {
  description = "password, provide through your ENV variables"
}
