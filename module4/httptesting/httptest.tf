variable "projectcode" {
    default = "8675309"
}
data "http" "example" {
  url = "https://checkpoint-api.hashicorp.com/v1/check/terraform"

  # Optional request headers
  request_headers {
    "Accept" = "application/json"
    "QueryText"  = "${terraform.workspace}-${var.projectcode}"
  }
}

output "response" {
    value = "${data.http.example.body}"
}