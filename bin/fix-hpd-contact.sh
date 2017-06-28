#!/bin/sh -ue
#
# One-off script to dedup the HPD contacts file.
#
srcfile='stage/1-incoming/hpd/contact.csv'
dstfile='stage/3-xtracted/hpd/contact.csv'
# A quick hack to uniqify the data rows, but keep the header in place.
head -1 $srcfile > $dstfile 
grep -v '^RegistrationContactID,' $srcfile | sort | uniq >> $dstfile 
