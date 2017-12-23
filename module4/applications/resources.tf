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

data "template_file" "testing" {
  count = "${length(data.terraform_remote_state.networking.private_subnets)}"
  template = "${file("templates/my.tpl")}"

  vars {
    tcount = "${count.index}"
    subnet = "${data.terraform_remote_state.networking.private_subnets[count.index]}"
    subnet_cidr = "${data.terraform_remote_state.networking.private_subnets_cidr_blocks[count.index]}"
  }
}

resource "null_resource" "nothing" {}



output "private_subnets" {
    value = "${data.terraform_remote_state.networking.private_subnets}"
}

output "rendered" {
  value = "${data.template_file.testing.*.rendered}"
}