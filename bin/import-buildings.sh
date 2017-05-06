#!/bin/bash -ue
stage='./stage'
indir="$stage/xtracted"

COMMAARGS='(DELIMITER \",\", FORMAT CSV, HEADER TRUE)'

echo '[import] inserting data ...'
python bin/dopg.py -c '"\copy flat.buildings FROM '$indir/buildings.csv' '$COMMAARGS';"'
echo '[import] done.'

