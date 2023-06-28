## Move this backend file to your network config when migrating state
terraform {
  cloud {
    # Organization ID
    organization = "ORGANIZATION_NAME"
    # Workspace ID
    workspaces {
      name = "web-network-dev"
    }
  }
}