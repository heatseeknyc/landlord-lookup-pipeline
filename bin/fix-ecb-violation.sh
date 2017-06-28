#!/bin/sh -ue
srcfile='stage/1-incoming/ecb/violation.csv'
dstfile='stage/3-xtracted/ecb/violation.csv'
python bin/fix-ecb-violation.py $srcfile $dstfile 
