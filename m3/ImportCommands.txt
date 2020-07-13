#Use the values output by the JuniorAdminIssue.ps1 or junior_admin.sh script

terraform import --var-file="terraform.tfvars" module.vpc.aws_route_table.private[2] rtb-0a76349c027b3c4d6
terraform import --var-file="terraform.tfvars" module.vpc.aws_route_table_association.private[2] subnet-0f385e7385e87e03f/rtb-0a76349c027b3c4d6
terraform import --var-file="terraform.tfvars" module.vpc.aws_subnet.private[2] subnet-0f385e7385e87e03f
terraform import --var-file="terraform.tfvars" module.vpc.aws_route_table_association.public[2] subnet-0739058b0103910e0/rtb-0284e5706ed6328aa
terraform import --var-file="terraform.tfvars" module.vpc.aws_subnet.public[2] subnet-0739058b0103910e0
