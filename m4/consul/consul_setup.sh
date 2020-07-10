# Create data directory
mkdir data

# Launch consul server instance

# Generate the bootstrap token
consul acl bootstrap

# Set CONSUL_TOKEN to SecretID

# Linux and MacOS
export CONSUL_HTTP_TOKEN=SECRETID_VALUE

# Windows
$env:CONSUL_HTTP_TOKEN="SECRETID_VALUE"

# Set up paths, policies, and tokens
terraform init
terraform plan -out consul.tfplan
terraform apply consul.tfplan

# Get token values for Mary and Sally
consul acl token read -id ACCESSOR_ID_MARY
consul acl token read -id ACCESSOR_ID_SALLY