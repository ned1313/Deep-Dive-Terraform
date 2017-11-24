##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  #access_key = "${var.aws_access_key}"
  #secret_key = "${var.aws_secret_key}"
  access_key = "AKIAI4UCKH6MLUB5QYYA"
  secret_key = "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"
  region     = "us-west-2"
}

##################################################################################
# BACKENDS
##################################################################################
terraform {
  backend "s3" {
    #bucket = "ddt-networking"
    #key = "module3/networking/net-prod.state"
    region = "us-west-2"
  }
}

##################################################################################
# DATA
##################################################################################

data "aws_availability_zones" "available" {}

##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "Terraform"

  cidr = "10.0.0.0/16"
  azs = "${slice(data.aws_availability_zones.available.names,0,var.subnet_count)}"
  private_subnets = ["10.0.1.0/24", "10.0.3.0/24"]
  public_subnets = ["10.0.0.0/24", "10.0.2.0/24"]

  enable_nat_gateway = true

  create_database_subnet_group = false

  
  tags {
  }
}






