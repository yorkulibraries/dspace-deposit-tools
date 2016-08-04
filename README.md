# dspace-deposit-tools

## build marc4j 
    $ cd lib/marc4j/
    $ ant
## convert MARC to RDF for sheet music
    $ java -cp lib/marc4j/build/marc4j-2.7.0.jar  org.marc4j.util.MarcXmlDriver -convert MARC8 -normalize -xsl xsl/MARC21slim2SMCDC.xsl <marc_input_file> -out <xml_output_file>
