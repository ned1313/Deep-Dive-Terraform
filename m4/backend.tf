## Move this backend file to m3 when migrating state
terraform {
  backend "consul" {
    address = "127.0.0.1:8500"
    scheme  = "http"
  }
}