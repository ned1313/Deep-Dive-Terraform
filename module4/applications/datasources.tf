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
    key     = "${terraform.workspace == "default" ? var.network_remote_state_key : local.workspace_key}"
    bucket  = "${var.network_remote_state_bucket}"
    region  = "us-west-2"
    profile = "${var.aws_profile}"
  }
}

data "aws_ami" "aws_linux" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-20*"]
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
  program = ["powershell.exe", "../scripts/getenvironment.ps1"]

  # Optional request headers
  query = {
    workspace   = "${terraform.workspace}"
    projectcode = "${var.projectcode}"
    url         = "${var.url}"
  }
}
