# Configure an AWS profile with proper credentials
aws configure --profile deep-dive

# Linux or MacOS
export AWS_PROFILE=deep-dive

# Windows
$env:AWS_PROFILE="deep-dive"

# Deploy the current environment
terraform init
terraform validate
terraform plan -out m3.tfplan
terraform apply "m3.tfplan"

# Now Jimmy ruins things

# Linux and MacOS: Run the junior_admin.sh script
./junior_admin.sh

# Windows: Install the AWS PowerShell module
Install-Module AWSPowerShell.NetCore -Scope CurrentUser

# Windows: Run the JuniorAdminIssue.ps1 script
.\JuniorAdminIssue.ps1

# Update your terraform.tfvars file to comment out the current 
# private_subnets, public_subnets, and subnet_count values and
# uncomment the updated values

# Run the import commands in ImportCommands.txt

terraform plan -out m3.tfplan

# There should be 3 changes where tags are added

terraform apply "m3.tfplan"

terraform destroy