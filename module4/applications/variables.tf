variable "network_remote_state_key" {
    default = "networking.state"
}
variable "network_remote_state_bucket" {
    default = "ddt-networking"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "key_name" {}

variable "ip_range" {
  default = "0.0.0.0/0"
}