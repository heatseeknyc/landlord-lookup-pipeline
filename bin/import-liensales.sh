#!/bin/bash -ue

stage='./stage'
COMMAARGS='(DELIMITER \",\", FORMAT CSV, HEADER TRUE)'

echo '[import] inserting data ...'
python bin/dopg.py -c '"\copy flat.liensales FROM '$stage/xtracted/liensales.csv' '$COMMAARGS';"' 
echo '[import] done.'

