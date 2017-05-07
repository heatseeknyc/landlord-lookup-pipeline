#!/bin/bash -ue

#
# A stripped-down fork of the 'import-rawdata.sh' script (restricted to just the pluto dataset).
# For testing and troubleshooting; not used in production.
#

stage='./stage'
indir="$stage/xtracted/pluto"

COMMAARGS='(DELIMITER \",\", FORMAT CSV, HEADER TRUE)'

echo '[import] inserting data ...'
python bin/dopg.py -c '"\copy flat.pluto_taxlot FROM '$indir/taxlot.csv' '$COMMAARGS';"'
echo '[import] done.'

