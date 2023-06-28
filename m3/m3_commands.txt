# Configure an AWS profile with proper credentials
aws configure --profile deep-dive

# Linux or MacOS
export AWS_PROFILE=deep-dive

# Windows
$env:AWS_PROFILE="deep-dive"

# Deploy the current environment using CloudFormation
cd ./m3/cloud_formation_template
aws cloudformation deploy --template-file="vpc_template.yaml" --stack-name dev-net --parameter-overrides EnvironmentName=globo-dev
aws cloudformation describe-stacks --stack-name dev-net --query 'Stacks[0].Outputs[].[OutputKey, OutputValue]' --output table > table.txt

# Copy the network config to the root directory
cd ../.. # Move up to the root directory

## PowerShell
copy .\m3\network_config_example\ .\network_config -Recurse

## Bash or zsh
cp ./m3/network_config_example ./network_config

# Retrieve the values to use in the import blocks
# They are in the table.txt file in the cloud_formation_template directory

# Now run a plan and see what happens
cd ./network_config
terraform init
terraform plan

# Looks like we need to create another object
terraform plan -generate-config-out="generated.tf"

# Update the VPC ID reference in the generated block to use the module VPC ID
# Move the block to the resources file and delete the generated file

# Run a plan again and note the imports and adds

terraform plan

# There should be 9 imports and 3 adds for default objects

terraform apply

# Add the environment input variable and tag
# and update the tags on the security group
terraform plan -out="tags.tfplan"
terraform apply tags.tfplan