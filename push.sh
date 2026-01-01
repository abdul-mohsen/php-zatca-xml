#!/bin/bash
source /home/ssda/.bashrc
cd /home/ssda/git/php-zatca-xml/

# Function to send invoice request
send_invoice_request() {

    fatoora -prod -sign -invoice $1 
    local XML_FILE="$(basename $1 .xml)_signed.xml"
	local QR_CODE=$(grep -oP '<cbc:EmbeddedDocumentBinaryObject[^>]*>\K[^<]*' $XML_FILE)

    fatoora -prod -invoiceRequest  -invoice $XML_FILE 
    JSON_PAYLOAD=$(cat generated-json-request-*.json)
    rm generated-json-request-*.json

    echo "Sending JSON payload: $JSON_PAYLOAD" > output

    local SANDBOX='https://gw-fatoora.zatca.gov.sa/e-invoicing/developer-portal'
    local SIMULATION='https://gw-fatoora.zatca.gov.sa/e-invoicing/simulation'
    local PRODUCTION='https://gw-fatoora.zatca.gov.sa/e-invoicing/core'
    URL="$PRODUCTION/invoices/reporting/single"
    # URL='https://gw-fatoora.zatca.gov.sa/e-invoicing/developer-portal/compliance/invoices'

    # Send the request
    response=$(curl -s -o res -w "%{http_code}" -X POST "$URL" \
      -H 'accept: application/json' \
      -H 'accept-language: en' \
      -H 'Clearance-Status: 1' \
      -H 'Accept-Version: V2' \
      -H "Authorization: $AUTHORIZATION" \
      -H 'Content-Type: application/json' \
      -d "$JSON_PAYLOAD")
	cat res
    cat res | jq

	bill_id=$(basename "$1" | cut -d'_' -f2 | cut -d'.' -f1)
	# Check the response code
	echo "bill number ${bill_id} - ${2}"
	if [[ $response -ge 200 && $response -le 299 ]]; then
	  if [ $2 = 0 ]; then
		echo "start sql"
		mysql -u "$DBUSER" -p"$PASSWORD" -h "$HOST" "$DBNAME" -e " UPDATE bill SET state = 3, qr_code = '$QR_CODE' WHERE id = ${bill_id}; "
		echo $QR_CODE
		echo "done sql"
	  else
		mysql -u "$DBUSER" -p"$PASSWORD" -h "$HOST" "$DBNAME" -e " UPDATE credit_note SET state = 3 WHERE bill_id = ${bill_id}; "
	  fi
	  echo "Request successful!"
	elif [[ $response -eq 409 ]]; then
	  echo "duplicate invoice"
	else
	  echo "Error: Received HTTP status $response"
	  exit 1
    fi

}

# Assign the OTP from the first argument
JSON_FILE="auth"

# Extract the Base64 values using jq
USERNAME_BASE64=$(jq -r '.binarySecurityToken' "$JSON_FILE")
PASSWORD_BASE64=$(jq -r '.secret' "$JSON_FILE")
COMPLIANCE_REQUEST_ID=$(jq -r '.requestID' "$JSON_FILE")
AUTHORIZATION="Basic $(echo -n "$USERNAME_BASE64:$PASSWORD_BASE64" | base64 | tr -d '\n')"
echo $AUTHORIZATION

# Directory containing XML files
DIRECTORY="examples/InvoiceSimplified/output/"  # Replace with your actual directory path

# Path to the .env file
ENV_FILE=".env"

# Check if the .env file exists
if [ ! -f "$ENV_FILE" ]; then
  echo "Error: .env file not found!"
  exit 1
fi

# Read and export variables from the .env file
export $(grep -v '^#' "$ENV_FILE" | xargs)
# Loop over all XML files in the directory

for XML_FILE in "$DIRECTORY"/*.xml; do
    if [[ -f "$XML_FILE" ]]; then  # Check if it's a file
        echo "Processing file: $XML_FILE"
        send_invoice_request "$XML_FILE" 0
        if [ $? = 0 ]; then
            echo "Process done"
            rm $XML_FILE
        else
            echo "Process failed"
        fi
    else
        echo "No XML files found in the directory."
    fi
done

DIRECTORY="examples/InvoiceSimplified/credit/output/"  # Replace with your actual directory path
echo "Pusing credit"

for XML_FILE in "$DIRECTORY"/*.xml; do
    if [[ -f "$XML_FILE" ]]; then  # Check if it's a file
        echo "Processing file: $XML_FILE"
        send_invoice_request "$XML_FILE" 1
        if [ $? = 0 ]; then
            echo "Process done"
            rm $XML_FILE
        else
            echo "Process failed"
        fi
    else
        echo "No XML files found in the directory."
    fi
done
# mv -f  *.xml /home/ssda/tosend/
mv -f  *.xml /var/www/html/downloads/  2> /dev/null
