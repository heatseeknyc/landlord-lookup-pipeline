#!/bin/bash -ue
stage='./stage'

PIPEARGS='(DELIMITER \"|\", FORMAT CSV, HEADER TRUE)'
COMMAARGS='(DELIMITER \",\", FORMAT CSV, HEADER TRUE)'

echo '[import] inserting data ...'
python bin/dopg.py -c '"\copy flat.taxbills FROM '$stage/taxbills-latest.csv' '$COMMAARGS';"' 
python bin/dopg.py -c '"\copy flat.registrations FROM '$stage/registrations.txt' '$PIPEARGS';"' 
python bin/dopg.py -c '"\copy flat.contacts FROM '$stage/contacts-clean.csv' '$PIPEARGS';"' 
python bin/dopg.py -c '"\copy flat.dhcr_tuples (bbl,bin) FROM '$stage/dhcr_tuples.csv' '$COMMAARGS';"' 
python bin/dopg.py -c '"\copy flat.pluto FROM '$stage/pluto-latest.csv' '$COMMAARGS';"' 
python bin/dopg.py -c '"\copy flat.buildings FROM '$stage/buildings-latest.csv' '$COMMAARGS';"' 
echo '[import] done.'

