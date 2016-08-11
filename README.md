# dspace-deposit-tools

## install required PHP libraries
    $ sudo apt-get install php5-curl php5-xsl

## Install File_MARC 
    $ sudo pear install --onlyreqdeps File_Marc-alpha

## build marc4j 
    $ cd lib/marc4j/
    $ ant
## convert MARC to MARCXML
    $ java -cp lib/marc4j/build/marc4j-2.7.0.jar org.marc4j.util.MarcXmlDriver -convert MARC8 -normalize -out <marcxml_output_file> <marc_input_file>

## deposit MARCXML
    $ php deposit_marcxml.php smc smc_marc.xml
