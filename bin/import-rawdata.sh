#!/bin/bash -ue
stage='./stage'

PIPEARGS='(DELIMITER \"|\", FORMAT CSV, HEADER TRUE)'
COMMAARGS='(DELIMITER \",\", FORMAT CSV, HEADER TRUE)'

echo '[import] inserting data ...'
python bin/dopg.py -c '"\copy flat.registrations FROM '$stage/registrations.txt' '$PIPEARGS';"' 
python bin/dopg.py -c '"\copy flat.contacts FROM '$stage/contacts-dedup.txt' '$PIPEARGS';"' 
python bin/dopg.py -c '"\copy flat.mapdata FROM '$stage/bbl_lat_lng.txt' '$COMMAARGS';"' 
python bin/dopg.py -c '"\copy flat.taxbills FROM '$stage/taxbill-latest.csv' '$COMMAARGS';"' 
echo '[import] done.'

