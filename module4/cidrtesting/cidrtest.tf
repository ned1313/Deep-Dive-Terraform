variable subnet_count {
    default = "2"
}

variable vpc_cidr {
    default = "10.0.0.0/16"
}

data "template_file" "private_cidrsubnet" {
    count = "${var.subnet_count}"

  template = "$${cidrsubnet(vpc_cidr,8,current_count)}"

  vars {
    vpc_cidr  = "${var.vpc_cidr}"
    current_count = "${count.index*2+1}"
  }
}

data "template_file" "public_cidrsubnet" {
    count = "${var.subnet_count}"

  template = "$${cidrsubnet(vpc_cidr,8,current_count)}"

  vars {
    vpc_cidr  = "${var.vpc_cidr}"
    current_count = "${count.index*2}"
  }
}

output private {
    value = "${data.template_file.private_cidrsubnet.*.rendered}"
}

output public {
    value = "${data.template_file.public_cidrsubnet.*.rendered}"
}