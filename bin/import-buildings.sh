#!/bin/bash -ue
stage='./stage'

COMMAARGS='(DELIMITER \",\", FORMAT CSV, HEADER TRUE)'

echo '[import] inserting data ...'
python bin/dopg.py -c '"\copy flat.buildings FROM '$stage/buildings-latest.csv' '$COMMAARGS';"' 
echo '[import] done.'
