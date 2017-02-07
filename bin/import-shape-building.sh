#!/bin/bash -ue
stage='./stage'

COMMAARGS='(DELIMITER \",\", FORMAT CSV, HEADER TRUE)'

echo '[import] inserting data ...'
python bin/dopg.py -c '"\copy flat.shape_building FROM '$stage/building_shapes.csv' '$COMMAARGS';"' 
echo '[import] done.'

