#!/bin/bash -ue

#
# Import taxbills table into the new provisional table in the 'temp' schema.
#
stage='./stage'
indir="$stage/xtracted/stable"

COMMAARGS='(DELIMITER \",\", FORMAT CSV, HEADER TRUE)'

echo '[import] inserting data ...'
python bin/dopg.py -c '"\copy flat.taxbills FROM '$indir/values-2016Q4.csv' '$COMMAARGS';"'
echo '[import] done.'

