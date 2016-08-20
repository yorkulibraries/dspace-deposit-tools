#!/bin/sh
EMAIL_RCPT=$2

MARC4J_JAR=lib/marc4j/build/marc4j-2.7.0.jar

MARC_FILE=$1
IDENTIFIERS_DIR=identifiers
CHECKSUMS_DIR=checksums
MD5_FILE=${CHECKSUMS_DIR}/smc.md5
TMP_MARCXML_FILE=/tmp/$$.xml

if [ -z "$MARC_FILE" ]; then
  echo "Usage: $0 path_to_marc_file email_address"
  exit
fi
if [ -z "$EMAIL_RCPT" ]; then
  echo "Usage: $0 path_to_marc_file email_address"
  exit
fi

LOGFILE=/tmp/$$.log
exec > $LOGFILE 2>&1

[ ! -d $IDENTIFIERS_DIR ] && mkdir $IDENTIFIERS_DIR
[ ! -d $CHECKSUMS_DIR ] && mkdir $CHECKSUMS_DIR

if [ ! -f "$MARC_FILE" ]; then
  echo "$MARC_FILE does not exist"
  exit
fi


changed=1
if [ -f $MD5_FILE ]; then
  md5sum --status -c $MD5_FILE
  changed=$?
fi 

if [ $changed -eq 1 ]; then
  # update the checksums
  md5sum $MARC_FILE > $MD5_FILE
  
  echo "converting $MARC_FILE to MARCXML"
  java -cp $MARC4J_JAR org.marc4j.util.MarcXmlDriver -convert MARC8 -normalize -out $TMP_MARCXML_FILE $MARC_FILE
  php deposit_marcxml.php smc $TMP_MARCXML_FILE
  mutt -s "YorkSpace Deposit Result" -a $TMP_MARCXML_FILE -- $EMAIL_RCPT < $LOGFILE
  rm $TMP_MARCXML_FILE
  rm $LOGFILE
fi

