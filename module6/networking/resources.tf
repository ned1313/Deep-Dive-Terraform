##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  profile = "${var.aws_profile}"
  region  = "us-west-2"
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
  name   = "ddt-${terraform.workspace}"

  cidr            = "${data.external.configuration.result.vpc_cidr_range}"
  azs             = "${slice(data.aws_availability_zones.available.names,0,data.external.configuration.result.vpc_subnet_count)}"
  private_subnets = "${data.template_file.private_cidrsubnet.*.rendered}"
  public_subnets  = "${data.template_file.public_cidrsubnet.*.rendered}"

  enable_nat_gateway = true

  create_database_subnet_group = false

  tags = "${local.common_tags}"
}
