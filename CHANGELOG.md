**2020-12-21**

ISSUES fixed
* Removed backend.tf file from m3 (not supposed to be there until you copy it over in m4)
* Added command to install `jq` if it's missing in the `junior_admin.sh` script in m3
* Added quotes for import commands in the `ImportCOmmands.txt` file in m3
* Removed route table ID references (they should not have been there)

0.14.3 Updates
* Change VPC module version to support 0.14 of Terraform
* Update the configurations to use the `terraform` and `required_providers` blocks
* exclude `hcl` files in `.gitignore`
* Add quota increase request
