#!/bin/bash

# Check if SSH key exists
KEY_FILE="my_key.pem"

if [ ! -f "$KEY_FILE" ]; then
    echo "ERROR: SSH key file '$KEY_FILE' not found!"
    echo ""
    echo "Please ensure you have your AWS key pair file in the current directory."
    echo "You can:"
    echo "1. Download your key pair from AWS Console"
    echo "2. Place it in this directory as 'my_key.pem'"
    echo "3. Set proper permissions: chmod 400 my_key.pem"
    echo ""
    echo "Or update the key_name in terraform.tfvars to match your existing key pair."
    exit 1
fi

# Check permissions
PERMS=$(stat -c "%a" "$KEY_FILE" 2>/dev/null || stat -f "%A" "$KEY_FILE" 2>/dev/null)
if [ "$PERMS" != "400" ] && [ "$PERMS" != "0400" ]; then
    echo "WARNING: SSH key permissions are not secure."
    echo "Setting proper permissions..."
    chmod 400 "$KEY_FILE"
fi

echo "SSH key '$KEY_FILE' found and properly configured."