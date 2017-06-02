#!/bin/bash -ue
stage='./stage'
indir="$stage/xtracted/nychpd"

PIPEARGS='(DELIMITER \"|\", FORMAT CSV, HEADER TRUE)'

echo '[import] inserting data ...'
python bin/dopg.py -c '"\copy flat.nychpd_contact FROM '$indir/contact-clean.csv' '$PIPEARGS';"' 
echo '[import] done.'

