locals {
  common_tags = {
    environment      = "${data.external.configuration.result.environment}"
    billing_code     = "${data.external.configuration.result.billing_code}"
    project_code     = "${data.external.configuration.result.project_code}"
    network_lead     = "${data.external.configuration.result.network_lead}"
    application_lead = "${data.external.configuration.result.application_lead}"
  }
}

data "template_file" "public_cidrsubnet" {
  count = "${data.external.configuration.result.vpc_subnet_count}"

  template = "$${cidrsubnet(vpc_cidr,8,current_count)}"

  vars {
    vpc_cidr      = "${data.external.configuration.result.vpc_cidr_range}"
    current_count = "${count.index*2+1}"
  }
}

data "template_file" "private_cidrsubnet" {
  count = "${data.external.configuration.result.vpc_subnet_count}"

  template = "$${cidrsubnet(vpc_cidr,8,current_count)}"

  vars {
    vpc_cidr      = "${data.external.configuration.result.vpc_cidr_range}"
    current_count = "${count.index*2}"
  }
}

data "external" "configuration" {
  program = ["powershell.exe", "../scripts/getenvironment.ps1"]

  # Optional request headers
  query = {
    workspace   = "${terraform.workspace}"
    projectcode = "${var.projectcode}"
    url         = "${var.url}"
  }
}
