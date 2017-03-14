#!/bin/bash -ue
stage='./stage'
indir="$stage/xtracted"

PIPEARGS='(DELIMITER \"|\", FORMAT CSV, HEADER TRUE)'
COMMAARGS='(DELIMITER \",\", FORMAT CSV, HEADER TRUE)'

echo '[import] inserting data ...'
python bin/dopg.py -c '"\copy flat.taxbills FROM '$indir/taxbills.csv' '$COMMAARGS';"' 
python bin/dopg.py -c '"\copy flat.registrations FROM '$indir/registrations.txt' '$PIPEARGS';"' 
python bin/dopg.py -c '"\copy flat.contacts FROM '$indir/contacts-clean.csv' '$PIPEARGS';"' 
python bin/dopg.py -c '"\copy flat.dhcr_tuples FROM '$indir/dhcr_tuples.csv' '$COMMAARGS';"' 
python bin/dopg.py -c '"\copy flat.pluto FROM '$indir/mappluto.csv' '$COMMAARGS';"' 
python bin/dopg.py -c '"\copy flat.buildings FROM '$indir/buildings.csv' '$COMMAARGS';"' 
echo '[import] done.'

