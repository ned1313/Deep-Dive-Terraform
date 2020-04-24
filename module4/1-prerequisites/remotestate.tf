##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "region" {
  default = "us-east-1"
}

#Bucket variables
variable "aws_networking_bucket" {
  default = "ddt-networking"
}

variable "aws_application_bucket" {
  default = "ddt-application"
}

variable "aws_dynamodb_table" {
  default = "ddt-tfstatelock"
}

#Your home holder path. 
# Windows - C:\\Users\\USERNAME
# Linux - /home/USERNAME
# Mac - /Users/USERNAME
variable "user_home_path" {}

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
# RESOURCES
##################################################################################

resource "random_integer" "rand" {
  min = 10000
  max = 99999
}

locals {

  dynamodb_table_name = "${var.aws_dynamodb_table}-${random_integer.rand.result}"
  s3_net_bucket_name  = "${var.aws_networking_bucket}-${random_integer.rand.result}"
  s3_app_bucket_name  = "${var.aws_application_bucket}-${random_integer.rand.result}"
}

data "template_file" "application_bucket_policy" {
  template = "${file("templates/bucket_policy.tpl")}"

  vars = {
    read_only_user_arn   = aws_iam_user.marymoe.arn
    full_access_user_arn = aws_iam_user.sallysue.arn
    s3_bucket            = local.s3_app_bucket_name
  }
}

data "template_file" "network_bucket_policy" {
  template = "${file("templates/bucket_policy.tpl")}"

  vars = {
    read_only_user_arn   = aws_iam_user.sallysue.arn
    full_access_user_arn = aws_iam_user.marymoe.arn
    s3_bucket            = local.s3_net_bucket_name
  }
}

data "template_file" "mary_moe_policy" {
  template = "${file("templates/user_policy.tpl")}"

  vars = {
    s3_rw_bucket       = local.s3_net_bucket_name
    s3_ro_bucket       = local.s3_app_bucket_name
    dynamodb_table_arn = aws_dynamodb_table.terraform_statelock.arn
  }
}

data "template_file" "sally_sue_policy" {
  template = "${file("templates/user_policy.tpl")}"

  vars = {
    s3_rw_bucket       = local.s3_app_bucket_name
    s3_ro_bucket       = local.s3_net_bucket_name
    dynamodb_table_arn = aws_dynamodb_table.terraform_statelock.arn
  }
}

resource "aws_dynamodb_table" "terraform_statelock" {
  name           = local.dynamodb_table_name
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "ddtnet" {
  bucket        = local.s3_net_bucket_name
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  policy = data.template_file.network_bucket_policy.rendered
}

resource "aws_s3_bucket" "ddtapp" {
  bucket        = local.s3_app_bucket_name
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  policy = data.template_file.application_bucket_policy.rendered
}

resource "aws_iam_user" "sallysue" {
  name = "sallysue"
}

resource "aws_iam_user_policy" "sallysue_rw" {
  name = "sallysue"
  user = aws_iam_user.sallysue.name

  policy = data.template_file.sally_sue_policy.rendered
}

resource "aws_iam_user" "marymoe" {
  name = "marymoe"
}

resource "aws_iam_access_key" "marymoe" {
  user = aws_iam_user.marymoe.name
}

resource "aws_iam_user_policy" "marymoe_rw" {
  name = "marymoe"
  user = aws_iam_user.marymoe.name

  policy = data.template_file.mary_moe_policy.rendered
}

resource "aws_iam_access_key" "sallysue" {
  user = aws_iam_user.sallysue.name
}

resource "aws_iam_group" "rdsadmin" {
  name = "RDSAdmin"
}

resource "aws_iam_group_policy_attachment" "rdsadmin-attach" {
  group      = aws_iam_group.rdsadmin.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_group" "ec2admin" {
  name = "EC2Admin"
}

resource "aws_iam_group_policy_attachment" "ec2admin-attach" {
  group      = aws_iam_group.ec2admin.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_membership" "add-ec2admin" {
  name = "add-ec2admin"

  users = [
    aws_iam_user.sallysue.name,
    aws_iam_user.marymoe.name,
  ]

  group = aws_iam_group.ec2admin.name
}

resource "aws_iam_group_membership" "add-rdsadmin" {
  name = "add-rdsadmin"

  users = [
    aws_iam_user.sallysue.name,
  ]

  group = aws_iam_group.rdsadmin.name
}

resource "local_file" "aws_keys" {
  content = <<EOF
[default]
aws_access_key_id = ${var.aws_access_key}
aws_secret_access_key = ${var.aws_secret_key}

[sallysue]
aws_access_key_id = ${aws_iam_access_key.sallysue.id}
aws_secret_access_key = ${aws_iam_access_key.sallysue.secret}

[marymoe]
aws_access_key_id = ${aws_iam_access_key.marymoe.id}
aws_secret_access_key = ${aws_iam_access_key.marymoe.secret}

EOF

  filename = "${var.user_home_path}/.aws/credentials"
}

##################################################################################
# OUTPUT
##################################################################################

output "networking_s3_bucket" {
  value = aws_s3_bucket.ddtnet.bucket
}

output "application_s3_bucket" {
  value = aws_s3_bucket.ddtapp.bucket
}

output "dynamodb_statelock" {
  value = aws_dynamodb_table.terraform_statelock.name
}