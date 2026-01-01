#!/bin/bash

echo "started process."

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
composer install  --prefer-dist --no-dev 2> /dev/null
cd examples/InvoiceSimplified

# Loop through each JSON file in the directory
for jsonFile in "$DIRECTORY"/*/*.json; do
    # Check if the file exists
    if [[ -f "$jsonFile" ]]; then
        echo "bill Processing file: $jsonFile"
        # Run the PHP script with the JSON file as an argument in the background
        php simplified_invoice.php "$jsonFile" &
        s=$?
        # check if the file is valid
        # Update the state in the database

        if [ $s -eq 0 ]; then
            echo "did work"
			bill_id=$(cat "$jsonFile" | jq .bill_id)
			mysql -u "$DBUSER" -p"$PASSWORD" -h "$HOST" "$DBNAME" -e "UPDATE bill SET state = 2 WHERE id = ${bill_id}; "

            rm "$jsonFile"
        else
            echo "failed to credit bil"
        fi
    else
        echo "No JSON files found in the directory."
    fi
done



echo "step credit"
# Directory containing JSON files
DIRECTORY="../../../bills_credit"
cd credit

# Loop through each JSON file in the directory
for jsonFile in "$DIRECTORY"/*/*.json; do
    # Check if the file exists
    if [[ -f "$jsonFile" ]]; then
        echo "creit Processing file: $jsonFile"
        # Run the PHP script with the JSON file as an argument in the background
        php simplified_credit_note.php "$jsonFile" &
        s=$?
        # check if the file is valid
        # Update the state in the database

        if [ $s -eq 0 ]; then
            echo "did work"
			bill_id=$(cat "$jsonFile" | jq .bill_id)
			mysql -u "$DBUSER" -p"$PASSWORD" -h "$HOST" "$DBNAME" -e "UPDATE credit_note SET state = 2 WHERE bill_id = ${bill_id}; "

            rm "$jsonFile"
        else
            echo "failed to credit bil"
        fi
    else
        echo "No JSON files found in the directory."
    fi
done

# Wait for all background processes to finish
wait
# rm output/*_Signed.xml

echo "All files processed."
