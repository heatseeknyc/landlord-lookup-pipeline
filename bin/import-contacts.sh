#!/bin/bash -ue
stage='./stage'

#
# A stripped-down fork of the 'import-rawdata.sh' script (restricted to just the registration contacts dataset).
# For testing and troubleshooting; not used in production.
#

PIPEARGS='(DELIMITER \"|\", FORMAT CSV, HEADER TRUE)'
COMMAARGS='(DELIMITER \",\", FORMAT CSV, HEADER TRUE)'

echo '[import] inserting data ...'
python bin/dopg.py -c '"\copy flat.contacts FROM '$stage/contacts-clean.txt' '$PIPEARGS';"' 
echo '[import] done.'

