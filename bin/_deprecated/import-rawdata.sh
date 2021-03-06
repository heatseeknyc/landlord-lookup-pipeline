#!/bin/bash -ue
stage='./stage'
indir="$stage/xtracted"

PIPEARGS='(DELIMITER \"|\", FORMAT CSV, HEADER TRUE)'
COMMAARGS='(DELIMITER \",\", FORMAT CSV, HEADER TRUE)'

echo '[import] inserting data ...'
python bin/dopg.py -c '"\copy flat.pluto FROM '$indir/mappluto.csv' '$COMMAARGS';"'
python bin/dopg.py -c '"\copy flat.buildings FROM '$indir/buildings.csv' '$COMMAARGS';"'
python bin/dopg.py -c '"\copy flat.registrations FROM '$indir/registrations.txt' '$PIPEARGS';"'
python bin/dopg.py -c '"\copy flat.contacts FROM '$indir/contacts-clean.csv' '$PIPEARGS';"'
python bin/dopg.py -c '"\copy flat.dhcr_pairs FROM '$indir/dhcr_pairs.csv' '$COMMAARGS';"'
python bin/dopg.py -c '"\copy flat.taxbills FROM '$indir/values-2016Q4.csv' '$COMMAARGS';"'
echo '[import] done.'

