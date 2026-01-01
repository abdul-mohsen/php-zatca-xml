#!/bin/bash

# Function to send invoice request
send_invoice_request() {
  # Assign the OTP from the first argument
  JSON_FILE="auth"

  # Extract the Base64 values using jq
  USERNAME_BASE64=$(jq -r '.binarySecurityToken' "$JSON_FILE")
  PASSWORD_BASE64=$(jq -r '.secret' "$JSON_FILE")
  COMPLIANCE_REQUEST_ID=$(jq -r '.requestID' "$JSON_FILE")
  AUTHORIZATION="Basic $(echo -n "$USERNAME_BASE64:$PASSWORD_BASE64" | base64 | tr -d '\n')"

  # Read the CSR from the file
  CSR_FILE="keys/prod.csr"  # Replace with the actual path to your CSR file
  CSR=$(<"$CSR_FILE")


  fatoora -sign -invoice $1 
  local XML_FILE="$(basename $1 .xml)_signed.xml"

  fatoora -invoiceRequest  -invoice $XML_FILE > /dev/null
  JSON_PAYLOAD=$(cat generated-json-request-*.json)
  rm generated-json-request-*.json

  echo "Sending JSON payload: $JSON_PAYLOAD" > output

  local SANDBOX='https://gw-fatoora.zatca.gov.sa/e-invoicing/developer-portal'
  local SIMULATION='https://gw-fatoora.zatca.gov.sa/e-invoicing/simulation'
  local PRODUCTION='https://gw-fatoora.zatca.gov.sa/e-invoicing/core'
  URL="$PRODUCTION/compliance/invoices"
  # URL='https://gw-fatoora.zatca.gov.sa/e-invoicing/developer-portal/compliance/invoices'

    # Send the request
    response=$(curl -s -o res -w "%{http_code}" -X POST "$URL" \
      -H 'accept: application/json' \
      -H 'accept-language: en' \
      -H "Authorization: $AUTHORIZATION" \
      -H 'Accept-Version: V2' \
      -H 'Content-Type: application/json' \
      -d "$JSON_PAYLOAD")
          cat res | jq

    # Check the response code
    if [ "$response" -ne 200 ]; then
      echo "Error: Received HTTP status $response"
    else
      echo "Request successful!"
    fi

  }
send_invoice_request "/var/www/html/downloads/0000027.xml"
send_invoice_request "/var/www/html/downloads/1000027.xml"
send_invoice_request "/var/www/html/downloads/2000027.xml"
