#!/bin/bash


# Assign the OTP from the first argument
JSON_FILE="auth"

# Extract the Base64 values using jq
USERNAME_BASE64=$(jq -r '.binarySecurityToken' "$JSON_FILE")
PASSWORD_BASE64=$(jq -r '.secret' "$JSON_FILE")
COMPLIANCE_REQUEST_ID=$(jq -r '.requestID' "$JSON_FILE")
AUTHORIZATION="Basic $(echo -n "$USERNAME_BASE64:$PASSWORD_BASE64" | base64 | tr -d '\n')"
echo "$AUTHORIZATION"
echo $COMPLIANCE_REQUEST_ID

# Make the POST request using curl
curl -i -X 'POST' \
  'https://gw-fatoora.zatca.gov.sa/e-invoicing/simulation/production/csids' \
  -H 'accept: application/json' \
  -H 'Accept-Version: V2' \
  -H "Authorization: $AUTHORIZATION" \
  -H 'Content-Type: application/json' \
  -d "{
  \"compliance_request_id\": \"$COMPLIANCE_REQUEST_ID\"
}" 

echo 
