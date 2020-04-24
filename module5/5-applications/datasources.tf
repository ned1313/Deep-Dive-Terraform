locals {
  common_tags = {
    environment      = "${data.external.configuration.result.environment}"
    billing_code     = "${data.external.configuration.result.billing_code}"
    project_code     = "${data.external.configuration.result.project_code}"
    network_lead     = "${data.external.configuration.result.network_lead}"
    application_lead = "${data.external.configuration.result.application_lead}"
  }

  workspace_key = "env:/${terraform.workspace}/${var.network_remote_state_key}"
}

data "terraform_remote_state" "networking" {
  backend = "s3"

  config {
    key            = "${terraform.workspace == "default" ? var.network_remote_state_key : local.workspace_key}"
    bucket         = "${var.network_remote_state_bucket}"
    region         = "us-west-2"
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "external" "configuration" {
  program = ["bash", "../scripts/getenvironment.sh"]

  # Optional request headers
  query = {
    workspace   = "${terraform.workspace}"
    projectcode = "${var.projectcode}"
    url         = "${var.url}"
  }
}