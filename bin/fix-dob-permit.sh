#!/bin/sh -ue
#
# One-off script to dedup the DOB current permits file. 
#
srcfile='stage/incoming/dob/permit.csv'
dstfile='stage/xtracted/dob/permit.csv'
grep -v '|' $srcfile > $dstfile 
