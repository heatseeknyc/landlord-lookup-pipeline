#!/bin/bash -ue

#
# Import taxbills table into the new provisional table in the 'temp' schema.
#
stage='./stage'
indir="$stage/xtracted"

COMMAARGS='(DELIMITER \",\", FORMAT CSV, HEADER TRUE)'

echo '[import] inserting data ...'
python bin/dopg.py -c '"\copy flat.dhcr2015 FROM '$indir/dhcr2015.csv' '$COMMAARGS';"'
echo '[import] done.'

