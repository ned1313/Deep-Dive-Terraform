##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "subnet_count" {
  default = 2
}

variable "region" {
  default = "us-east-1"
}