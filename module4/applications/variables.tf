variable "network_remote_state_key" {
    default = "networking.state"
}
variable "network_remote_state_bucket" {
    default = "ddt-networking"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "key_name" {}

variable "instance_type" {
  default = "t2.nano"
}

variable "amis" {
  default = {
    us-east-1 = "ami-60b6c60a"
    us-west-2 = "ami-f0091d91"
  }
}

variable "asg_min" {
  default = "2"
}

variable "asg_max" {
  default = "10"
}

variable "ip_range" {
  default = "0.0.0.0/0"
}