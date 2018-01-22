##################################################################################
# BACKENDS
##################################################################################
terraform {
  backend "s3" {
    key            = "networking.state"
    region         = "us-west-2"
    dynamodb_table = "ddt-tfstatelock"
  }
}
