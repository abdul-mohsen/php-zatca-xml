<?php
require_once __DIR__ . '/../../vendor/autoload.php';

use Saleh7\Zatca\Mappers\InvoiceMapper;
use Saleh7\Zatca\GeneratorInvoice;
use Saleh7\Zatca\Helpers\Certificate;
use Saleh7\Zatca\InvoiceSigner;


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

// Map the data to an Invoice object
$invoiceMapper = new InvoiceMapper();
$invoice = $invoiceMapper->mapToInvoice($invoiceData);

// Generate the invoice XML
$xmlFileName = pathinfo($jsonFile, PATHINFO_FILENAME) . '.xml';
$outputXML = GeneratorInvoice::invoice($invoice)->saveXMLFile($xmlFileName);
echo "Simplified Invoice Generated Successfully\n";

/*// get invoice.xml ..*/
/*$xmlInvoice = file_get_contents("output/{$xmlFileName}");*/
/**/
/*// get from ZATCA certificate ..*/
/*$json_certificate = file_get_contents('ZATCA_certificate_data.json');*/
/**/
/*// Decode JSON*/
/*$json_data = json_decode($json_certificate, true, 512, JSON_THROW_ON_ERROR);*/
/**/
/*// get certificate*/
/*$certificate = $json_data['certificate'];*/
/**/
/*//get secret */
/*$secret = $json_data['secret'];*/
/**/
/*// get private key*/
/*$privateKey = file_get_contents('private.pem');*/
/**/
/*$cleanPrivateKey = trim(str_replace(["-----BEGIN PRIVATE KEY-----", "-----END PRIVATE KEY-----"], "", $privateKey));*/
/**/
/*$certificate = (new Certificate(*/
/*    $certificate,*/
/*    $cleanPrivateKey,*/
/*    $secret*/
/*));*/
/**/
/*// sign the invoice XML with the certificate*/
/*$xmlFileName = pathinfo($jsonFile, PATHINFO_FILENAME) . '_Signed.xml';*/
/**/
/*InvoiceSigner::signInvoice($xmlInvoice, $certificate)->saveXMLFile($xmlFileName);*/
/*echo "Simplified Invoice Signed Successfully\n";*/
