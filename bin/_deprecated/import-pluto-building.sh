#!/bin/bash -ue
stage='./stage'
indir="$stage/xtracted/pluto"

COMMAARGS='(DELIMITER \",\", FORMAT CSV, HEADER TRUE)'

echo '[import] inserting data ...'
python bin/dopg.py -c '"\copy flat.pluto_building FROM '$indir/building.csv' '$COMMAARGS';"'
echo '[import] done.'

