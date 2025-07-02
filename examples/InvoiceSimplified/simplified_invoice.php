<?php
require_once __DIR__ . '/../../vendor/autoload.php';

use Saleh7\Zatca\Mappers\InvoiceMapper;
use Saleh7\Zatca\GeneratorInvoice;
use Saleh7\Zatca\Helpers\Certificate;
use Saleh7\Zatca\InvoiceSigner;
use Saleh7\Zatca\ZatcaAPI;

/* // Sample data (can be from JSON, array, database, etc.) */
/* $invoiceData = [ */
/*     'uuid' => '3cf5ee18-ee25-44ea-a444-2c37ba7f28be', # idk */
/*     'id' => 'SME00023', # idk */
/*     'issueDate' => '2024-20-06', # */
/*     'issueTime' => '17:41:08', */
/*     'currencyCode' => 'SAR', */
/*     'taxCurrencyCode' => 'SAR', */
/*     'note' => 'This is a sample invoice note.', */
/*     'languageID' => 'en', */
/*     'invoiceType' => [ */
/*         'invoice' => 'simplified', */
/*         'type' => 'invoice', */
/*         'isThirdParty' => true, */
/*         'isNominal' => false, */
/*         'isExport' => true, */
/*         'isSummary' => false, */
/*         'isSelfBilled' => true */
/*     ], */
/*     'additionalDocuments' => [ */
/*         [ */
/*             'id' => 'ICV', */
/*             'uuid' => '10' */
/*         ], */
/*         [ */
/*             'id' => 'PIH', */
/*             'attachment' => [ */
/*                 'content' => 'NWZlY2ViNjZmZmM4NmYzOGQ5NTI3ODZjNmQ2OTZjNzljMmRiYzIzOWRkNGU5MWI0NjcyOWQ3M2EyN2ZiNTdlOQ==', */
/*             ] */
/*         ], */
/*     ], # idk */
/*     'supplier' => [ */
/*         'registrationName' => 'مؤسسة مريم عبدالرحيم الفضل لبيع قطع غيار السيارات', # check if it works in ar */
/*         'taxId' => '310365582100003', */
/*         'identificationId' => '7012359738', */
/*         'identificationType' => 'CRN', */
/*         'address' => [ */
/*             'street' => 'al amir talal', */
/*             'buildingNumber' => '4397', */
/*             'subdivision' => 'ar rashieyah 3rd dist', */
/*             'city' => 'al mubarraz', */
/*             'postalZone' => '36342', */
/*             'country' => 'SA' */
/*         ] */
/*     ], */
/*     'customer' => [ */
/*         'registrationName' => 'Fatoora Samples', */
/*         'taxId' => '399999999800003', */
/*         'address' => [ */
/*             'street' => 'Salah Al-Din', */
/*             'buildingNumber' => '1111', */
/*             'subdivision' => 'Al-Murooj', */
/*             'city' => 'Riyadh', */
/*             'postalZone' => '12222', */
/*             'country' => 'SA' */
/*         ] */
/*     ], */
/*     'paymentMeans' => [ */
/*         'code' => '10' */
/*     ], */
/*     'allowanceCharges' => [ */
/*         [ */
/*             'isCharge' => false, */
/*             'reason' => 'discount', */
/*             'amount' => 0.00, */
/*             'taxCategories' => [ */
/*                 [ */
/*                     'percent' => 15, */
/*                     'taxScheme' => [ */
/*                         'id' => 'VAT' */
/*                     ] */
/*                 ], */
/*                 [ */
/*                     'percent' => 15, */
/*                     'taxScheme' => [ */
/*                         'id' => 'VAT' */
/*                     ] */
/*                 ] */
/*             ] */
/*         ] */
/*     ], */
/*     'taxTotal' => [ */
/*         'taxAmount' => 30.15, // 14.85 (Book) + 15.30 (Pen) */
/*         'subTotals' => [ */
/*             [ */
/*                 'taxableAmount' => 201, // Sum of line extension amounts: 99 + 102 = 201 */
/*                 'taxAmount' => 30.15, */
/*                 'taxCategory' => [ */
/*                     'percent' => 15, */
/*                     'taxScheme' => [ */
/*                         'id' => 'VAT' */
/*                     ] */
/*                 ] */
/*             ] */
/*         ] */
/*     ], */
/*     'legalMonetaryTotal' => [ */
/*         'lineExtensionAmount' => 201, // 99 (Book) + 102 (Pen) */
/*         'taxExclusiveAmount' => 201, */
/*         'taxInclusiveAmount' => 231.15, // 201 + 30.15 */
/*         'prepaidAmount' => 0, */
/*         'payableAmount' => 231.15, */
/*         'allowanceTotalAmount' => 0 */
/*     ], */
/*     'invoiceLines' => [ */
/*         [ */
/*             'id' => 1, */
/*             'unitCode' => 'PCE', */
/*             'quantity' => 33, */
/*             'lineExtensionAmount' => 99, // 3 * 33 */
/*             'item' => [ */
/*                 'name' => 'Book', */
/*                 'classifiedTaxCategory' => [ */
/*                     [ */
/*                         'percent' => 15, */
/*                         'taxScheme' => [ */
/*                             'id' => 'VAT' */
/*                         ] */
/*                     ] */
/*                 ], */
/*             ], */
/*             'price' => [ */
/*                 'amount' => 3, // price per unit without tax */
/*                 'unitCode' => 'UNIT', */
/*                 'allowanceCharges' => [ */
/*                     [ */
/*                         'isCharge' => false, */
/*                         'reason' => 'discount', */
/*                         'amount' => 0.00 */
/*                     ] */
/*                 ] */
/*             ], */
/*             'taxTotal' => [ */
/*                 'taxAmount' => 14.85, // 99 * 15% = 14.85 */
/*                 'roundingAmount' => 113.85 // 99 + 14.85 */
/*             ] */
/*         ], */
/*         [ */
/*             'id' => 2, */
/*             'unitCode' => 'PCE', */
/*             'quantity' => 3, */
/*             'lineExtensionAmount' => 102, // 34 * 3 = 102 */
/*             'item' => [ */
/*                 'name' => 'Pen', */
/*                 'classifiedTaxCategory' => [ */
/*                     [ */
/*                         'percent' => 15, */
/*                         'taxScheme' => [ */
/*                             'id' => 'VAT' */
/*                         ] */
/*                     ] */
/*                 ], */
/*             ], */
/*             'price' => [ */
/*                 'amount' => 34, // price per unit without tax */
/*                 'unitCode' => 'UNIT', */
/*                 'allowanceCharges' => [ */
/*                     [ */
/*                         'isCharge' => false, */
/*                         'reason' => 'discount', */
/*                         'amount' => 0.00 */
/*                     ] */
/*                 ] */
/*             ], */
/*             'taxTotal' => [ */
/*                 'taxAmount' => 15.30, // 102 * 15% = 15.30 */
/*                 'roundingAmount' => 117.30 // 102 + 15.30 */
/*             ] */
/*         ] */
/*     ] */
/* ]; */


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

// get invoice.xml ..
$xmlInvoice = file_get_contents("output/{$xmlFileName}");
$certificate = (new Certificate(
    'MIID3jCCA4SgAwIBAgITEQAAOAPF90Ajs/xcXwABAAA4AzAKBggqhkjOPQQDAjBiMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxEzARBgoJkiaJk/IsZAEZFgNnb3YxFzAVBgoJkiaJk/IsZAEZFgdleHRnYXp0MRswGQYDVQQDExJQUlpFSU5WT0lDRVNDQTQtQ0EwHhcNMjQwMTExMDkxOTMwWhcNMjkwMTA5MDkxOTMwWjB1MQswCQYDVQQGEwJTQTEmMCQGA1UEChMdTWF4aW11bSBTcGVlZCBUZWNoIFN1cHBseSBMVEQxFjAUBgNVBAsTDVJpeWFkaCBCcmFuY2gxJjAkBgNVBAMTHVRTVC04ODY0MzExNDUtMzk5OTk5OTk5OTAwMDAzMFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAEoWCKa0Sa9FIErTOv0uAkC1VIKXxU9nPpx2vlf4yhMejy8c02XJblDq7tPydo8mq0ahOMmNo8gwni7Xt1KT9UeKOCAgcwggIDMIGtBgNVHREEgaUwgaKkgZ8wgZwxOzA5BgNVBAQMMjEtVFNUfDItVFNUfDMtZWQyMmYxZDgtZTZhMi0xMTE4LTliNTgtZDlhOGYxMWU0NDVmMR8wHQYKCZImiZPyLGQBAQwPMzk5OTk5OTk5OTAwMDAzMQ0wCwYDVQQMDAQxMTAwMREwDwYDVQQaDAhSUlJEMjkyOTEaMBgGA1UEDwwRU3VwcGx5IGFjdGl2aXRpZXMwHQYDVR0OBBYEFEX+YvmmtnYoDf9BGbKo7ocTKYK1MB8GA1UdIwQYMBaAFJvKqqLtmqwskIFzVvpP2PxT+9NnMHsGCCsGAQUFBwEBBG8wbTBrBggrBgEFBQcwAoZfaHR0cDovL2FpYTQuemF0Y2EuZ292LnNhL0NlcnRFbnJvbGwvUFJaRUludm9pY2VTQ0E0LmV4dGdhenQuZ292LmxvY2FsX1BSWkVJTlZPSUNFU0NBNC1DQSgxKS5jcnQwDgYDVR0PAQH/BAQDAgeAMDwGCSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCIGGqB2E0PsShu2dJIfO+xnTwFVmh/qlZYXZhD4CAWQCARIwHQYDVR0lBBYwFAYIKwYBBQUHAwMGCCsGAQUFBwMCMCcGCSsGAQQBgjcVCgQaMBgwCgYIKwYBBQUHAwMwCgYIKwYBBQUHAwIwCgYIKoZIzj0EAwIDSAAwRQIhALE/ichmnWXCUKUbca3yci8oqwaLvFdHVjQrveI9uqAbAiA9hC4M8jgMBADPSzmd2uiPJA6gKR3LE03U75eqbC/rXA==',
    'MHQCAQEEIL14JV+5nr/sE8Sppaf2IySovrhVBtt8+yz+g4NRKyz8oAcGBSuBBAAKoUQDQgAEoWCKa0Sa9FIErTOv0uAkC1VIKXxU9nPpx2vlf4yhMejy8c02XJblDq7tPydo8mq0ahOMmNo8gwni7Xt1KT9UeA==',
    'secret'
));

// sign the invoice XML with the certificate
$xmlFileName = pathinfo($jsonFile, PATHINFO_FILENAME) . '_Signed.xml';

InvoiceSigner::signInvoice($xmlInvoice, $certificate)->saveXMLFile($xmlFileName);
echo "Simplified Invoice Signed Successfully\n";
