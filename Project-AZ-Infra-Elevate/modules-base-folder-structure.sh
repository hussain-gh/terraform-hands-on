#!/bin/bash
# filepath: Project-AZ-Infra-Elevate/create_structure.sh

set -e

# Create base folder
mkdir -p Project-AZ-Infra-Elevate
cd Project-AZ-Infra-Elevate

# Modules and submodules
declare -A modules=(
  [resource_group]=""
  [network/vnet]=""
  [network/nsg]=""
  [network/public-ip]=""
  [network/azure-loadbalancer]=""
  [network/application-loadbalancer]=""
  [security]=""
  [compute/vm]=""
  [compute/vmss]=""
  [compute/aks]=""
  [storage]=""
)

for mod in "${!modules[@]}"; do
  mkdir -p "modules/$mod"
  touch "modules/$mod/main.tf" "modules/$mod/variables.tf" "modules/$mod/outputs.tf"
done

# Environments
for env in dev stage prod; do
  mkdir -p "envs/$env"
  touch "envs/$env/main.tf" "envs/$env/variables.tf" "envs/$env/terraform.tfvars" "envs/$env/backend.tf"
done

# Root files
touch README.md .gitignore

echo "Project-AZ-Infra-Elevate