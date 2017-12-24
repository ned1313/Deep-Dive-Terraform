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
  vpc_id = "${data.terraform_remote_state.networking.vpc_id}"
  tags {
      Name = "terraform_bastion_ssh"
  }
}

resource "aws_security_group" "nat" {
  name = "vpc_nat"
  description = "Allow traffic to pass from the private subnet to the internet"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${data.terraform_remote_state.networking.private_subnets_cidr_blocks}"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${data.terraform_remote_state.networking.private_subnets_cidr_blocks}"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${data.terraform_remote_state.networking.private_subnets_cidr_blocks}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${data.terraform_remote_state.networking.vpc_id}"
  tags {
      Name = "terraform"
  }
}

resource "aws_security_group" "web_access_from_nat_sg" {
  name = "private_subnet_web_access"
  description = "Allow web access to the private subnet from the public subnet (via NAT instance)"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${data.terraform_remote_state.networking.public_subnets_cidr_blocks}"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${data.terraform_remote_state.networking.public_subnets_cidr_blocks}"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${data.terraform_remote_state.networking.public_subnets_cidr_blocks}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${data.terraform_remote_state.networking.vpc_id}"
  tags {
      Name = "terraform"
  }
}

resource "aws_security_group" "webapp_http_inbound_sg" {
  name = "demo_webapp_http_inbound"
  description = "Allow HTTP from Anywhere"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${data.terraform_remote_state.networking.vpc_id}"
  tags {
      Name = "terraform_demo_webapp_http_inbound"
  }
}

resource "aws_security_group" "webapp_ssh_inbound_sg" {
  name = "demo_webapp_ssh_inbound"
  description = "Allow SSH from certain ranges"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.ip_range}"]
  }
  vpc_id = "${data.terraform_remote_state.networking.vpc_id}"
  tags {
      Name = "terraform_demo_webapp_ssh_inbound"
  }
}

resource "aws_security_group" "webapp_outbound_sg" {
  name = "demo_webapp_outbound"
  description = "Allow outbound connections"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${data.terraform_remote_state.networking.vpc_id}"
  tags {
      Name = "terraform_demo_webapp_outbound"
  }
}