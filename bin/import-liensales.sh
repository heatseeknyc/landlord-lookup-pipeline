#!/bin/bash -ue

stage='./stage'
indir="$stage/xtracted/stable"

COMMAARGS='(DELIMITER \",\", FORMAT CSV, HEADER TRUE)'

echo '[import] inserting data ...'
python bin/dopg.py -c '"\copy flat.liensales FROM '$indir/liensales.csv' '$COMMAARGS';"' 
echo '[import] done.'

