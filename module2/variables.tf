##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "region" {
  default = "us-east-1"
}

variable "subnet_count" {
  default = 2
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  type = list
}

variable "public_subnets" {
  type = list
}

