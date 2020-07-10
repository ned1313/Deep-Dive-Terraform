##################################################################################
# VARIABLES
##################################################################################

#AWS variables
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
    s3_net_bucket_name = "${var.aws_networking_bucket}-${random_integer.rand.result}"
    s3_app_bucket_name = "${var.aws_application_bucket}-${random_integer.rand.result}"
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
  bucket = local.s3_net_bucket_name
  acl    = "private"
  force_destroy = true
  
  versioning {
    enabled = true
  }

      policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "ReadforAppTeam",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.sallysue.arn}"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${local.s3_net_bucket_name}/*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.marymoe.arn}"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${local.s3_net_bucket_name}",
                "arn:aws:s3:::${local.s3_net_bucket_name}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_s3_bucket" "ddtapp" {
  bucket = local.s3_app_bucket_name
  acl    = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
        policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "ReadforNetTeam",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.marymoe.arn}"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${local.s3_app_bucket_name}/*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.sallysue.arn}"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${local.s3_app_bucket_name}",
                "arn:aws:s3:::${local.s3_app_bucket_name}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_group" "ec2admin" {
  name = "EC2Admin"
}

resource "aws_iam_group_policy_attachment" "ec2admin-attach" {
  group      = aws_iam_group.ec2admin.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_user" "sallysue" {
  name = "sallysue"
}

resource "aws_iam_user_policy" "sallysue_rw" {
    name = "sallysue"
    user = aws_iam_user.sallysue.name
    policy= <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${local.s3_app_bucket_name}",
                "arn:aws:s3:::${local.s3_app_bucket_name}/*"
            ]
        },
                {
            "Effect": "Allow",
            "Action": ["dynamodb:*"],
            "Resource": [
                "${aws_dynamodb_table.terraform_statelock.arn}"
            ]
        }
   ]
}
EOF
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
   policy= <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${local.s3_net_bucket_name}",
                "arn:aws:s3:::${local.s3_net_bucket_name}/*"
            ]
        },
                {
            "Effect": "Allow",
            "Action": ["dynamodb:*"],
            "Resource": [
                "${aws_dynamodb_table.terraform_statelock.arn}"
            ]
        }
   ]
}
EOF
}

resource "aws_iam_access_key" "sallysue" {
    user = aws_iam_user.sallysue.name
}

resource "aws_iam_group_membership" "add-ec2admin" {
  name = "add-ec2admin"

  users = [
    aws_iam_user.sallysue.name,
  ]

  group = aws_iam_group.ec2admin.name
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

output "A-sally-access-key" {
    value = aws_iam_access_key.sallysue.id
}

output "B-sally-secret-key" {
    value = aws_iam_access_key.sallysue.secret
}

output "C-mary-access-key" {
    value = aws_iam_access_key.marymoe.id
}

output "D-mary-secret-key" {
    value = aws_iam_access_key.marymoe.secret
}

output "E-net-bucket-name" {
    value = local.s3_net_bucket_name
}

output "F-app-bucket-name" {
    value = local.s3_app_bucket_name
}

output "G-dynamodb-table-name" {
    value = local.dynamodb_table_name
}