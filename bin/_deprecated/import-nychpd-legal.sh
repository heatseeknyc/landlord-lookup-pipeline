#!/bin/bash -ue
stage='./stage'
indir="$stage/xtracted/nychpd"

PIPEARGS='(DELIMITER \"|\", FORMAT CSV, HEADER TRUE)'

echo '[import] inserting data ...'
python bin/dopg.py -c '"\copy flat.nychpd_legal FROM '$indir/litigation.txt' '$PIPEARGS';"' 
echo '[import] done.'

