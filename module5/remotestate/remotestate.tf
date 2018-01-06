##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "aws_networking_bucket" {
  default = "ddt-networking"
}

variable "aws_application_bucket" {
  default = "ddt-application"
}

variable "aws_dynamodb_table" {
  default = "ddt-tfstatelock"
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-west-2"
}

##################################################################################
# RESOURCES
##################################################################################
data "template_file" "application_bucket_policy" {
  template = "${file("templates/bucket_policy.tpl")}"

  vars {
    read_only_user_arn   = "${aws_iam_user.networking.arn}"
    full_access_user_arn = "${aws_iam_user.application.arn}"
    s3_bucket            = "${var.aws_application_bucket}"
  }
}

data "template_file" "network_bucket_policy" {
  template = "${file("templates/bucket_policy.tpl")}"

  vars {
    read_only_user_arn   = "${aws_iam_user.application.arn}"
    full_access_user_arn = "${aws_iam_user.networking.arn}"
    s3_bucket            = "${var.aws_networking_bucket}"
  }
}

data "template_file" "networking_policy" {
  template = "${file("templates/user_policy.tpl")}"

  vars {
    s3_rw_bucket          = "${var.aws_networking_bucket}"
    s3_ro_bucket          = "${var.aws_application_bucket}"
    dynamodb_table_arn = "${aws_dynamodb_table.terraform_statelock.arn}"
  }
}

data "template_file" "application_policy" {
  template = "${file("templates/user_policy.tpl")}"

  vars {
    s3_rw_bucket          = "${var.aws_application_bucket}"
    s3_ro_bucket          = "${var.aws_networking_bucket}"
    dynamodb_table_arn = "${aws_dynamodb_table.terraform_statelock.arn}"
  }
}

resource "aws_dynamodb_table" "terraform_statelock" {
  name           = "${var.aws_dynamodb_table}"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "ddtnet" {
  bucket        = "${var.aws_networking_bucket}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  policy = "${data.template_file.network_bucket_policy.rendered}"
}

resource "aws_s3_bucket" "ddtapp" {
  bucket        = "${var.aws_application_bucket}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  policy = "${data.template_file.application_bucket_policy.rendered}"
}

resource "aws_iam_user" "application" {
  name = "application"
}

resource "aws_iam_user_policy" "application_rw" {
  name = "application"
  user = "${aws_iam_user.application.name}"

  policy = "${data.template_file.application_policy.rendered}"
}

resource "aws_iam_user" "networking" {
  name = "networking"
}

resource "aws_iam_access_key" "networking" {
  user = "${aws_iam_user.networking.name}"
}

resource "aws_iam_user_policy" "networking_rw" {
  name = "networking"
  user = "${aws_iam_user.networking.name}"

  policy = "${data.template_file.networking_policy.rendered}"
}

resource "aws_iam_access_key" "application" {
  user = "${aws_iam_user.application.name}"
}

resource "aws_iam_group" "rdsadmin" {
  name = "RDSAdmin"
}

resource "aws_iam_group_policy_attachment" "rdsadmin-attach" {
  group      = "${aws_iam_group.rdsadmin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_group" "ec2admin" {
  name = "EC2Admin"
}

resource "aws_iam_group_policy_attachment" "ec2admin-attach" {
  group      = "${aws_iam_group.ec2admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_membership" "add-ec2admin" {
  name = "add-ec2admin"

  users = [
    "${aws_iam_user.application.name}",
    "${aws_iam_user.networking.name}"
  ]

  group = "${aws_iam_group.ec2admin.name}"
}

resource "aws_iam_group_membership" "add-rdsadmin" {
  name = "add-rdsadmin"

  users = [
    "${aws_iam_user.application.name}"
  ]

  group = "${aws_iam_group.rdsadmin.name}"
}

##################################################################################
# OUTPUT
##################################################################################

output "application_access_key" {
    value = "${aws_iam_access_key.application.id}"
}

output "application_secret_key" {
    value = "${aws_iam_access_key.application.secret}"
}

output "networking_access_key" {
    value = "${aws_iam_access_key.networking.id}"
}

output "networking_secret_key" {
    value = "${aws_iam_access_key.networking.secret}"
}