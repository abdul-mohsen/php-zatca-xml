// Map the data to an Invoice object


<?php
require_once __DIR__ . '/../../../vendor/autoload.php';

use Saleh7\Zatca\Mappers\InvoiceMapper;
use Saleh7\Zatca\GeneratorInvoice;


// Check if the file path is provided as an argument
if ($argc < 2) {
    echo "Usage: php script.php <path_to_json_file>\n";
    exit(1);
}

// Get the file path from the command-line argument
$jsonFile = $argv[1];

// Check if the file exists
if (!file_exists($jsonFile)) {
    echo "Error: File not found: $jsonFile\n";
    exit(1);
}

// Read the JSON file
$jsonData = file_get_contents($jsonFile);

// Decode the JSON data into a PHP associative array
$invoiceData = json_decode($jsonData, true);

// Check if the data was decoded successfully
if ($invoiceData === null) {
    echo "Error decoding JSON: " . json_last_error_msg() . "\n";
    exit(1);
}
$invoiceMapper = new InvoiceMapper();
$invoice = $invoiceMapper->mapToInvoice($invoiceData);


// Generate the invoice XML
$xmlFileName = pathinfo($jsonFile, PATHINFO_FILENAME) . '.xml';
$outputXML = GeneratorInvoice::invoice($invoice)->saveXMLFile($xmlFileName);
echo "Simplified credit Invoice Generated Successfully\n";
