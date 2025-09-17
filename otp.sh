#!/bin/bash

# Check if the OTP argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <OTP>"
    exit 1
fi

# Assign the OTP from the first argument
OTP=$1

# Read the CSR from the file
CSR_FILE="generated-csr-20250901060536.csr"  # Replace with the actual path to your CSR file
CSR=$(<"$CSR_FILE")

# Make the POST request using curl with the correct base URL and path
curl -X 'POST' \
  'https://gw-fatoora.zatca.gov.sa/e-invoicing/simulation/compliance' \
  -H 'accept: application/json' \
  -H "OTP: $OTP" \
  -H 'Accept-Version: V2' \
  -H 'Content-Type: application/json' \
  -d "{
  \"csr\": \"$CSR\"
}"
