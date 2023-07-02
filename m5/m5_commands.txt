# Start by setting the GitHub token environment variable
# PowerShell
$env:GITHUB_TOKEN="TOKEN_VALUE"

# bash or zsh
export GITHUB_TOKEN=TOKEN_VALUE

# Head into the m5/github_config directory
cd ./m5/github_config

# initialize and apply the Terraform config
terraform init
terraform apply

# Head into the network_config directory
cd ../../network_config

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

# Create the github actions folders
mkdir .github
mkdir .github/workflows

# Copy the terraform.yml file to the workflows folder
cp ../m5/terraform.yml ./.github/workflows/

# Rename the backend file to backend_local.tf
mv backend.tf backend_local.tf

# Add backend_local.tf to the .gitignore file
# Add the changes to git
git add .

# Commit the changes
git commit -m "Add CI workflow"

# Push the changes to GitHub
git push

# Fix formatting and push updates
terraform fmt
git add .
git commit -m "Fix formatting"
git push

# Setting up Terraform Cloud to GitHub connection
# Go to the m5/terraform_cloud_config directory
cd ../m5/terraform_cloud_config
terraform init

# Replace the organization name with your org name
# PowerShell environment variable
terraform apply -var="gh_pat=$env:GITHUB_TOKEN" -var="organization=ORG_NAME"

# Bash or zsh environment variable
terraform apply -var="gh_pat=$GITHUB_TOKEN" -var="organization=ORG_NAME"

# Create a new branch called add-third-subnet
git checkout -b add-third-subnet

# Commit code changes to branch
git add .
git commit -m "Add third subnet and tags"
git push --set-upstream origin add-third-subnet

# Add variable values before creating pull request