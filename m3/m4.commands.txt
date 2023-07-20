## First let's try out some terraform state commands
## Go to the m3 folder and run the state commands

# View all the Terraform resources
terraform state list

# Now let's look at a specific resource
terraform state show module.vpc.aws_vpc.this[0]

# We can also view all the state data
terraform state pull

## Now it's time to deploy our local Consul server node
## Download the consul executable from https://www.consul.io/downloads

# Go into the consul subfolder in m4
cd ../m4/consul

# Create a data subdirectory
mkdir data

# Launch consul server instance
consul agent -bootstrap -config-file="config/consul-config.hcl" -bind="127.0.0.1"

# Open a separate terminal window to run the rest of the commands
# Make sure you are back in the m4/consul directory
cd m4/consul

# Generate the bootstrap token
consul acl bootstrap

# Set CONSUL_TOKEN to SecretID

# Linux and MacOS
export CONSUL_HTTP_TOKEN=SECRETID_VALUE

# Windows
$env:CONSUL_HTTP_TOKEN="SECRETID_VALUE"

## Now we're going to configure Consul using Terraform 
# Set up paths, policies, and tokens
terraform init
terraform plan -out consul.tfplan
terraform apply consul.tfplan

# Get token values for Mary and Sally and record them for later
consul acl token read -id ACCESSOR_ID_MARY
consul acl token read -id ACCESSOR_ID_SALLY

# Go back to the main m4 folder
cd ..

## Now let's set up the Consul backend and migrate the state

# Copy the backend.tf file to m3
cp backend.tf ..\m3\backend.tf

# Move to the m3 folder
cd ..\m3

# Now let's set the Consul token to Mary Moe
# Replace SECRETID_VALUE with Mary Moe's secret ID
# Linux and MacOS
export CONSUL_HTTP_TOKEN=SECRETID_VALUE

# Windows
$env:CONSUL_HTTP_TOKEN="SECRETID_VALUE"

# Now we can initialize the backend config
terraform init -backend-config="path=networking/state/globo-primary"

# Change the enable_nat_gateway to true in the resources.tf file

# Now run terraform plan and apply
terraform plan -out nat.tfplan
terraform apply nat.tfplan

# Open a second terminal
# Export the Consul token again
# Try to run a terraform plan
terraform plan

## You can stop your Consul instance if you want now, or leave it running
## for the next module

## We are going to keep using the infrastructure in AWS for m5, so don't destroy it!