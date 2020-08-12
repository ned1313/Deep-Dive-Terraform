##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  version = "~>2.0"
  region     = var.region
}

provider "consul" {
  address    = "${var.consul_address}:${var.consul_port}"
  datacenter = var.consul_datacenter
}

##################################################################################
# DATA
##################################################################################

data "aws_availability_zones" "available" {}

data "consul_keys" "networking" {
  key {
      name = "networking"
      path = terraform.workspace == "default" ? "networking/configuration/globo-primary/net_info" : "networking/configuration/globo-primary/${terraform.workspace}/net_info"
  }
  
  key {
    name = "common_tags"
    path = "networking/configuration/globo-primary/common_tags"
  }
}

##################################################################################
# LOCALS
##################################################################################

locals {
  cidr_block = jsondecode(data.consul_keys.networking.var.networking)["cidr_block"]
  subnet_count = jsondecode(data.consul_keys.networking.var.networking)["subnet_count"]
  common_tags = merge({
        Environment = terraform.workspace
      },
      jsondecode(data.consul_keys.networking.var.common_tags)
    )
}

##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.44.0"

  name = "globo-primary-${terraform.workspace}"

  cidr            = local.cidr_block
  azs = slice(data.aws_availability_zones.available.names,0,local.subnet_count)
  private_subnets = data.template_file.private_cidrsubnet.*.rendered
  public_subnets = data.template_file.public_cidrsubnet.*.rendered

  enable_nat_gateway = true

  create_database_subnet_group = false

  tags = local.common_tags
}
