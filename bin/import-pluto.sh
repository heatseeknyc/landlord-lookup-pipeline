#!/bin/bash -ue

#
# A stripped-down fork of the 'import-rawdata.sh' script (restricted to just the pluto dataset).
# For testing and troubleshooting; not used in production.
#

stage='./stage'
indir="$stage/xtracted"

COMMAARGS='(DELIMITER \",\", FORMAT CSV, HEADER TRUE)'

echo '[import] inserting data ...'
python bin/dopg.py -c '"\copy flat.pluto FROM '$indir/mappluto.csv' '$COMMAARGS';"'
echo '[import] done.'

