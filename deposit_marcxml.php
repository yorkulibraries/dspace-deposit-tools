<?php
if (count($argv) < 3) {
    die_usage();
}

$config = $argv[1];
$marcxml_file = $argv[2];

if (empty($config) || empty($marcxml_file)) {
    die_usage();
}

$config_file = 'config/' . $config . '.php';
if (!file_exists($config_file)) {
    die("File $config_file does not exist.\n");
}

if (!file_exists($marcxml_file)) {
    die("File $marcxml_file does not exist.\n");
}

// set exception handler to save the identifiers to file
set_exception_handler('custom_exception_handler');

// load specified config file
require_once($config_file);

// load the deposited identifiers
$identifiers = load_identifiers($config);

// load sword client 
require_once('lib/swordappv2-php-library/swordappclient.php');

// Initiatiate the SWORD client
$sword = new SWORDAPPClient();

// get the service document
$sd = $sword->servicedocument($servicedocument, $user, $password, '');
if ($sd->sac_status != 200) {
    print "Received HTTP status code: " . $sd->sac_status . " (" . $sd->sac_statusmessage . ")\n";
    die;
}

// Load XSLT Stylesheet
$stylesheet = new DOMDocument;
$stylesheet->load($xsl_file);

// Setup XSLT processor
$xsl = new XSLTProcessor();
$xsl->importStyleSheet($stylesheet);

// load MARCXML parser
require_once('File/MARCXML.php');

// Retrieve a set of MARCXML records from the file
$records = new File_MARCXML($marcxml_file);

// transform each marcxml record and deposit to dspace
$atom_entry_file = tempnam(sys_get_temp_dir(), $argv[0]);
while ($record = $records->next()) {
    $doc = new DOMDocument;
    if ($doc->loadXML($record->toXML())) {
        $atom_doc = $xsl->transformToDoc($doc);
        if ($atom_doc !== false) {
            $nl = $atom_doc->getElementsByTagNameNS('http://purl.org/dc/terms/', 'identifier');
            if ($nl->length) {
                $identifier = $nl->item(0)->nodeValue;
                print "==============================================================\n";
                print "About to deposit record: $identifier\n";
                if (!in_array($identifier, $identifiers)) {
                    if ($atom_doc->save($atom_entry_file)) {
                        $response = $sword->depositAtomEntry($depositlocation, $user, $password, '', $atom_entry_file, $sac_inprogress = true);
                        if (! (($response->sac_status >= 200) && ($response->sac_status < 300)) ) {
                            print "ERROR: Received HTTP status code: " . $response->sac_status . " (" . $response->sac_statusmessage . ")\n";
                            print $atom_doc->saveXML();
                        }
                        $identifiers[] = $identifier;
                    }
                } else {
                    print "$identifier may have been deposited already, skipping it.\n";
                }
            } else {
                print "ERROR: No dcterms:identifier tag found in atom entry.\n";
                print $atom_doc->saveXML();
            }
        }
    }
}
save_identifiers($config, $identifiers);

function die_usage() {
    die("Usage: php $argv[0] config marcxml_file\n");
}

function load_identifiers($config) {
    $file = "identifiers/{$config}";
    if (!file_exists($file)) {
        return array();
    }
    $identifiers = file($file, FILE_IGNORE_NEW_LINES);
    return array_unique($identifiers);
}

function save_identifiers($config, $identifiers) {
    $file = "identifiers/{$config}";
    $backup = $file . '-' . time();
    
    // make a backup copy of the file
    copy($file, $backup);
    
    // write the content of the array to the file
    file_put_contents($file, implode(PHP_EOL, $identifiers));
}

function custom_exception_handler($exception) {
    global $config, $identifiers;
    save_identifiers($config, $identifiers);
}
?>
