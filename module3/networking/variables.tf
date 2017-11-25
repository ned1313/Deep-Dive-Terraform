##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "subnet_count" {
  default = 2
}

variable "network_bucket_name" {
  default = "ddt-networking"
}

