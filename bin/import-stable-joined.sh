#!/bin/bash -ue
stage='./stage'
indir="$stage/xtracted/stable"

COMMAARGS='(DELIMITER \",\", FORMAT CSV, HEADER TRUE)'

echo '[import] inserting data ...'
python bin/dopg.py -c '"\copy flat.stable_joined FROM '$indir/joined-mini.csv' '$COMMAARGS';"'
echo '[import] done.'

