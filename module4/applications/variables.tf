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

variable "instance_type" {
  default = "t2.micro"
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

#RDS variable
variable "rds_storage" {
  default = "5"
}

variable "rds_engine" {
  default     = "mysql"
  description = "Engine type, example values mysql, postgres"
}

variable "rds_engine_version" {
  description = "Engine version"
  default     = "5.6.37"
}

variable "rds_multi_az" {
  description = "Multi-AZ or not"
  default     = false
}

variable "rds_instance_class" {
  default     = "db.t2.micro"
  description = "Instance class"
}

variable "rds_db_name" {
  default     = "testdb"
  description = "db name"
}

variable "rds_username" {
  default     = "ddtuser"
  description = "User name"
}

variable "rds_password" {
  description = "password, provide through your ENV variables"
}
