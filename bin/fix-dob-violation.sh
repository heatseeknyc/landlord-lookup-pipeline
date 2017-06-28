#!/bin/sh -ue
srcfile='stage/1-incoming/dob/violation.csv'
dstfile='stage/3-xtracted/dob/violation.csv'
python bin/fix-dob-violation.py $srcfile $dstfile 
