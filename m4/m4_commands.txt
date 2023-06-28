# Make sure your AWS profile is set
# Linux or MacOS
export AWS_PROFILE=deep-dive

# Windows
$env:AWS_PROFILE="deep-dive"

## First let's try out some terraform state commands
## Go to the network_config folder and run the state commands

# View all the Terraform resources
terraform state list

# Now let's look at a specific resource
terraform state show module.main.aws_vpc.this[0]

# We can also view all the state data
terraform state pull

## Now it's time to migrate our state data to Terraform cloud
## Create a terraform cloud account and organization called deep-dive-<your_initials>
## Sign up for an account here: https://app.terraform.io/public/signup/account

## Login into Terraform Cloud to get an user access token
terraform login

# Copy the backend file from the m4 directory to the network_config
cp ../m4/backend.tf .

# Update the backend info and run Terraform init to migrate state data
terraform init

# Now run a Terraform plan and note that it fails
terraform plan

# After adding AWS credentials, run a Terraform apply
terraform apply
