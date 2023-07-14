# Create SSH Key pair for aws instances using a module
module "ssh_keys" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "~>2.0.0"

  key_name           = "${local.name_prefix}-tdd-keys"
  create_private_key = true
}
