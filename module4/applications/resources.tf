data "terraform_remote_state" "networking" {
  backend = "s3"
  config {
    key = "networking.state"
    bucket = "ddt-networking"
    region = "us-west-2"
    aws_access_key = "AKIAIVOLLTK6HSHSIHDA"
    aws_secret_key = "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"
  }
}

resource "null_resource" "nothing" {}

output "vpc-info" {
    value = "${data.terraform_remote_state.networking.private_subnets}"
}