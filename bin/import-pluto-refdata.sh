#!/bin/bash -ue
stage='./stage'
indir="$stage/xtracted/pluto"

COMMAARGS='(DELIMITER \",\", FORMAT CSV, HEADER TRUE)'

echo '[import] inserting data ...'
python bin/dopg.py -c '"\copy flat.pluto_refdata_bldgclass FROM '$indir/refdata-bldgclass.csv' '$COMMAARGS';"'
python bin/dopg.py -c '"\copy flat.pluto_refdata_landuse FROM '$indir/refdata-landuse.csv' '$COMMAARGS';"'
echo '[import] done.'

