#!/bin/bash -ue
# "Unpacks" (that is, uncompresses) the taxbills archive.
# Since the file is big, this can take a while (25s or more).

destfile='stage/unpack/rawdata.csv'
echo "taxbills to $destfile .."
gunzip stage/incoming/rawdata.csv.gz --stdout > $destfile 
