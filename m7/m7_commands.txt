# Set AWS_PROFILE

# Linux or MacOS
export AWS_PROFILE=deep-dive

# Windows
$env:AWS_PROFILE="deep-dive"

## PowerShell
copy .\m7\application_config_example\ .\application_config -Recurse

## Bash or zsh
cp -r ./m7/application_config_example ./application_config

## Create Git Repository
# Start by setting the GitHub token environment variable
# PowerShell
$env:GITHUB_TOKEN="TOKEN_VALUE"

# bash or zsh
export GITHUB_TOKEN=TOKEN_VALUE

# Head into the m7/github_config_application directory
cd ./m7/github_config_application

# initialize and apply the Terraform config
terraform init
terraform apply

# Head into the application_config directory
cd ../../application_config

# Run git init
git init --initial-branch=main

# Copy the example gitignore file
cp ../m5/gitignore.example .gitignore

# Add files to git
git add .

# Commit files to git
git commit -m "Initial commit"

# Add remote origin
git remote add origin ORIGIN_URL

# Track main branch
git fetch
git branch --set-upstream-to="origin/main" main

# Push code to GitHub
git push origin --force

# Make sure checks complete
# Add new workspace to Terraform Cloud linked to Repository
# Add the necessary variable inputs using the portal or commands below
aws ec2 describe-vpcs --region=us-east-1 --filters "Name=tag:Name, Values=globo-dev" --query Vpcs[].VpcId --output text
aws ec2 describe-subnets --region=us-east-1 --filters "Name=vpc-id,Values=vpc-0fa3eb2daaeae0e29" --query Subnets[].SubnetId

# Check config of first EC2 instance
ssh -i PATH_TO_PEM_FILE ec2-user@PUBLIC_IP_ADDRESS

# Switch to networking config
cd ../network_config

# Create a new branch called tfe-outputs
git checkout main
git pull

git checkout -b tfe-outputs

# Make code changes
# Commit code changes to branch
git add .
git commit -m "Switch to using tfe_outputs"
git push --set-upstream origin tfe-outputs

# Go through the code deployment process
# Update network workspace state sharing

# Go to application config directory
cd ../application_config

# Create a new branch called tfe-outputs
git checkout -b tfe-outputs

# Make code changes
# Commit code changes to branch
git add .
git commit -m "Switch to using tfe_outputs"
git push --set-upstream origin tfe-outputs

# Add new variable values to application workspace
# Create pull request and merge once there are no changes

# Merge the changes back to the main branch in GitHub too
