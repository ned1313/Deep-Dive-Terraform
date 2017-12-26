##################################################################################
# BACKENDS
##################################################################################
terraform {
  backend "s3" {
    key            = "application.state"
    region         = "us-west-2"
    profile        = "sallysue"
    dynamodb_table = "ddt-tfstatelock"
  }
}
