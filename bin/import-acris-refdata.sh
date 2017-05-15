#!/bin/bash -ue

stage='./stage'
COMMAARGS='(DELIMITER \",\", FORMAT CSV, HEADER TRUE)'

echo '[import] inserting data ...'
python bin/dopg.py -c '"\copy flat.acris_master_codes FROM '$stage/xtracted/acris/master-codes.csv' '$COMMAARGS';"' 
echo '[import] done.'

