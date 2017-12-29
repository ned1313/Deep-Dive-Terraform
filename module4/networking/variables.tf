##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "projectcode" {
  default = "8675309"
}

variable "url" {
  default = "https://4rpwd825o5.execute-api.us-west-2.amazonaws.com/test/tdd_ddb_query"
}
