##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-west-2"
}

##################################################################################
# DATA
##################################################################################

data "terraform_remote_state" "networking" {
  backend = "s3"
  config {
    key = "${var.network_remote_state_key}"
    bucket = "${var.network_remote_state_bucket}"
    region = "us-west-2"
    aws_access_key = "${var.aws_access_key}"
    aws_secret_key = "${var.aws_secret_key}"
  }
}

##################################################################################
# RESOURCES
##################################################################################

resource "aws_security_group" "bastion_ssh_sg" {
  name = "bastion_ssh"
  description = "Allow SSH to Bastion host from approved ranges"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.ip_range}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${aws_vpc.default.id}"
  tags {
      Name = "terraform_bastion_ssh"
  }
}

output "private_subnets" {
    value = "${data.terraform_remote_state.networking.private_subnets}"
}