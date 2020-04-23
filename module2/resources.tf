##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  version = "~>2.0"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
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

  cidr = var.cidr_block
  azs = slice(data.aws_availability_zones.available.names,0,var.subnet_count)
  private_subnets = var.private_subnets
  public_subnets = var.public_subnets

  enable_nat_gateway = true

  create_database_subnet_group = false

  
  tags = {
  }
}






