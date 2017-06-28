#!/bin/sh -ue
#
# One-off script to dedup the DOB current permits file. 
#
srcfile='stage/1-incoming/dob/permit.csv'
dstfile='stage/3-xtracted/dob/permit.csv'
grep -v '|' $srcfile > $dstfile 
