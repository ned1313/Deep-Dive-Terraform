locals {
  template_data = [
    {
      path_type = "key_prefix"
      path = "applications/"
      policy = "write"
    },
    {
      path_type = "key_prefix"
      path = "networking/state/"
      policy = "read"
    }
  ]
}

data "template_file" "test" {
  template = file("policy.tpl")
  vars = {
    rules = local.template_data
  }
}

output "template_data" {
  value = data.template_file.test.rendered
}