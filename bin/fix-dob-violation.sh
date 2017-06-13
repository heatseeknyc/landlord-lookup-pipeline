#!/bin/sh -ue
srcfile='stage/incoming/dob/violation.csv'
dstfile='stage/xtracted/dob/violation.csv'
python bin/fix-dob-violation.py $srcfile $dstfile 
