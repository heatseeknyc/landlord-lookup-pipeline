#!/bin/bash -ue
# "Unpacks" (that is, uncompresses) the taxbills archive.
# Since the file is big, this can take a while (25s or more).
gunzip stage/incoming/rawdata.csv.gz --stdout > stage/unpack/rawdata.csv
