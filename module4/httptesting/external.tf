variable "projectcode" {
    default = "8675309"
}

variable "url" {
    default = "https://4rpwd825o5.execute-api.us-west-2.amazonaws.com/test/tdd_ddb_query"
}
data "external" "example" {
    program = ["powershell.exe", "./getenvironment.ps1"]

  # Optional request headers
  query = {
    workspace = "${terraform.workspace}"
    projectcode = "${var.projectcode}"
    url = "${var.url}"
  }
}

output "result" {
    value = "${data.external.example.result.vpc_subnet_count}"
}
