#!/bin/bash


# Path to the .env file
ENV_FILE=".env"
# Check if the .env file exists
if [ ! -f "$ENV_FILE" ]; then
  echo "Error: .env file not found!"
  exit 1
fi

# Read and export variables from the .env file
export $(grep -v '^#' "$ENV_FILE" | xargs)

# Directory containing JSON files
DIRECTORY="../../bills"
composer install  --prefer-dist --no-dev
cd examples/InvoiceSimplified
rm  examples/InvoiceSimplified/output/*

# Loop through each JSON file in the directory
for jsonFile in "$DIRECTORY"/*/*.json; do
    # Check if the file exists
    if [[ -f "$jsonFile" ]]; then
        echo "Processing file: $jsonFile"
        # Run the PHP script with the JSON file as an argument in the background
        php simplified_invoice.php "$jsonFile" &
        # check if the file is valid
        # Update the state in the database

        bill_id=$(cat "$jsonFile" | jq .bill_id)
        mysql -u "$DBUSER" -p"$PASSWORD" -h "$HOST" "$DBNAME" -e "UPDATE bill SET state = 2 WHERE id = ${bill_id}; "
        rm "$jsonFile"
    else
        echo "No JSON files found in the directory."
    fi
done

# Wait for all background processes to finish
wait
# rm output/*_Signed.xml

echo "All files processed."
