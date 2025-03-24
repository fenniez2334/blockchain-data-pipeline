#!/bin/bash

# Get the external IP of the VM using Terraform output
EXTERNAL_IP=$(terraform output -raw vm_external_ip)

# Define the SSH config file path
SSH_CONFIG=~/.ssh/config

# Check if the host config already exists in the file
if grep -q "Host blockchain-data-pipeline" "$SSH_CONFIG"; then
    # Update the existing HostName with the new IP
    sed -i.bak "/^Host blockchain-data-pipeline$/,/^$/ s/^    HostName.*/    HostName $EXTERNAL_IP/" "$SSH_CONFIG"
    echo "Updated existing HostName with new IP: $EXTERNAL_IP"
else
    # Append the host config if it doesn't exist
    cat <<EOL >> "$SSH_CONFIG"

Host blockchain-data-pipeline
    HostName $EXTERNAL_IP
    User fenniez
    IdentityFile ~/.ssh/gcp
EOL
    echo "Added new host config with IP: $EXTERNAL_IP"
fi
