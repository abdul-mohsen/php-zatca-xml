
#!/bin/bash

# Function to send invoice request
send_invoice_request() {
    local XML_FILE="$1"
    local URL="https://gw-fatoora.zatca.gov.sa/e-invoicing/developer-portal/invoices/clearance/single"

    # Extract the UUID from the XML file
    local UUID=$(grep -oP '<cbc:UUID>\K[0-9a-fA-F-]{36}' "$XML_FILE" )

    # Read the XML data as a string
    local XML_DATA=$(<"$XML_FILE")

    # Encode the XML data in Base64
    local BASE64_XML_DATA=$(base64 "$XML_FILE" | tr -d '\n')  # Remove newlines

    # Compute the SHA256 hash of the XML data
    local INVOICE_HASH=$(echo "$XML_DATA" | sha256sum | awk '{ print $1 }')

    # Prepare the JSON payload
    local JSON_PAYLOAD=$(jq -n \
      --arg invoiceHash "$INVOICE_HASH" \
      --arg uuid "$UUID" \
      --arg file_data "$BASE64_XML_DATA" \
      '{invoiceHash: $invoiceHash, uuid: $uuid, invoice:  $file_data}')

    # Debugging output
    # echo "Processing file: $XML_FILE"
    echo "UUID: $UUID"
    # echo "Base64 XML Data: $BASE64_XML_DATA"
    # echo "Invoice Hash: $INVOICE_HASH"
    echo "Sending JSON payload: $JSON_PAYLOAD" > output

    # Send the request
    response=$(curl -s -o res -w "%{http_code}" -X POST "$URL" \
      -H 'accept: application/json' \
      -H 'accept-language: en' \
      -H 'Clearance-Status: 1' \
      -H 'Accept-Version: V2' \
      -H 'Authorization: Basic VFVsSlJETnFRME5CTkZOblFYZEpRa0ZuU1ZSRlVVRkJUMEZRUmprd1FXcHpMM2hqV0hkQlFrRkJRVFJCZWtGTFFtZG5jV2hyYWs5UVVWRkVRV3BDYVUxU1ZYZEZkMWxMUTFwSmJXbGFVSGxNUjFGQ1IxSlpSbUpIT1dwWlYzZDRSWHBCVWtKbmIwcHJhV0ZLYXk5SmMxcEJSVnBHWjA1dVlqTlplRVo2UVZaQ1oyOUthMmxoU21zdlNYTmFRVVZhUm1ka2JHVklVbTVaV0hBd1RWSnpkMGRSV1VSV1VWRkVSWGhLVVZWc2NFWlRWVFZYVkRCc1JGSldUa1JSVkZGMFVUQkZkMGhvWTA1TmFsRjNUVlJGZUUxRWEzaFBWRTEzVjJoalRrMXFhM2ROVkVFMVRVUnJlRTlVVFhkWGFrSXhUVkZ6ZDBOUldVUldVVkZIUlhkS1ZGRlVSVzFOUTFGSFFURlZSVU5vVFdSVVYwWTBZVmN4TVdKVFFsUmpSMVpzV2tOQ1ZWcFhUbTlKUms0eFkwaENjMlZUUWsxV1JWRjRSbXBCVlVKblRsWkNRWE5VUkZaS2NHVlhSbXRoUTBKRFkyMUdkVmt5WjNoS2FrRnJRbWRPVmtKQlRWUklWbEpVVmtNd05FOUVXVEJOZWtWNFRrUlZkRTE2YXpWUFZHczFUMVJyTlU5VVFYZE5SRUY2VFVaWmQwVkJXVWhMYjFwSmVtb3dRMEZSV1VaTE5FVkZRVUZ2UkZGblFVVnZWME5MWVRCVFlUbEdTVVZ5VkU5Mk1IVkJhME14VmtsTFdIaFZPVzVRY0hneWRteG1OSGxvVFdWcWVUaGpNREpZU21Kc1JIRTNkRkI1Wkc4NGJYRXdZV2hQVFcxT2J6aG5kMjVwTjFoME1VdFVPVlZsUzA5RFFXZGpkMmRuU1VSTlNVZDBRbWRPVmtoU1JVVm5ZVlYzWjJGTGEyZGFPSGRuV25kNFQzcEJOVUpuVGxaQ1FWRk5UV3BGZEZaR1RsVm1SRWwwVmtaT1ZXWkVUWFJhVjFGNVRXMVplRnBFWjNSYVZGcG9UV2t3ZUUxVVJUUk1WR3hwVGxSbmRGcEViR2hQUjFsNFRWZFZNRTVFVm0xTlVqaDNTRkZaUzBOYVNXMXBXbEI1VEVkUlFrRlJkMUJOZW1zMVQxUnJOVTlVYXpWUFZFRjNUVVJCZWsxUk1IZERkMWxFVmxGUlRVUkJVWGhOVkVGM1RWSkZkMFIzV1VSV1VWRmhSRUZvVTFWc1NrVk5hbXQ1VDFSRllVMUNaMGRCTVZWRlJIZDNVbFV6Vm5kalIzZzFTVWRHYW1SSGJESmhXRkp3V2xoTmQwaFJXVVJXVWpCUFFrSlpSVVpGV0N0WmRtMXRkRzVaYjBSbU9VSkhZa3R2TjI5alZFdFpTekZOUWpoSFFURlZaRWwzVVZsTlFtRkJSa3AyUzNGeFRIUnRjWGR6YTBsR2VsWjJjRkF5VUhoVUt6bE9iazFJYzBkRFEzTkhRVkZWUmtKM1JVSkNSemgzWWxSQ2NrSm5aM0pDWjBWR1FsRmpkMEZ2V21aaFNGSXdZMFJ2ZGt3eVJuQlpWRkYxWlcxR01Ga3lSWFZhTWpreVRHNU9hRXd3VG14amJsSkdZbTVLZG1KSGQzWlZSa3BoVWxWc2RXUnRPWEJaTWxaVVVUQkZNRXh0VmpSa1IyUm9aVzVSZFZveU9USk1iWGgyV1RKR2MxZ3hRbE5YYTFaS1ZHeGFVRk5WVGtaVk1FNUNUa014UkZGVFozaExVelZxWTI1UmQwUm5XVVJXVWpCUVFWRklMMEpCVVVSQloyVkJUVVIzUjBOVGMwZEJVVkZDWjJwalZrSjNVWFpOUXpCSFNsTnpSMEZSVVVKbmFtTldRMGxIUjNGQ01rVXdVSE5UYUhVeVpFcEpaazhyZUc1VWQwWldiV2d2Y1d4YVdWaGFhRVEwUTBGWFVVTkJVa2wzU0ZGWlJGWlNNR3hDUWxsM1JrRlpTVXQzV1VKQ1VWVklRWGROUjBORGMwZEJVVlZHUW5kTlEwMURZMGREVTNOSFFWRlJRbWRxWTFaRFoxRmhUVUpuZDBObldVbExkMWxDUWxGVlNFRjNUWGREWjFsSlMzZFpRa0pSVlVoQmQwbDNRMmRaU1V0dldrbDZhakJGUVhkSlJGTkJRWGRTVVVsb1FVeEZMMmxqYUcxdVYxaERWVXRWWW1OaE0zbGphVGh2Y1hkaFRIWkdaRWhXYWxGeWRtVkpPWFZ4UVdKQmFVRTVhRU0wVFRocVowMUNRVVJRVTNwdFpESjFhVkJLUVRablMxSXpURVV3TTFVM05XVnhZa012Y2xoQlBUMD06Q2tZc0VYZlY4YzFnRkhBdEZXb1p2NzNwR012aC9ReW80THpLTTJoLzhIZz0=' \
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

# Directory containing XML files
DIRECTORY="examples/InvoiceSimplified/output/"  # Replace with your actual directory path

# Loop over all XML files in the directory

for XML_FILE in "$DIRECTORY"/*.xml; do
    if [[ -f "$XML_FILE" ]]; then  # Check if it's a file
        echo "Processing file: $XML_FILE"
        send_invoice_request "$XML_FILE"
        exit 1
    else
        echo "No XML files found in the directory."
    fi
done

