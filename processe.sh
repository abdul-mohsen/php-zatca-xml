#!/bin/bash

# Directory containing JSON files
DIRECTORY="../../sample"
composer install  --prefer-dist --no-dev
cd examples/InvoiceSimplified

# Loop through each JSON file in the directory
for jsonFile in "$DIRECTORY"/*.json; do
    # Check if the file exists
    if [[ -f "$jsonFile" ]]; then
        echo "Processing file: $jsonFile"
        # Run the PHP script with the JSON file as an argument in the background
        php simplified_invoice.php "$jsonFile" &
    else
        echo "No JSON files found in the directory."
    fi
done

# Wait for all background processes to finish
wait

echo "All files processed."
