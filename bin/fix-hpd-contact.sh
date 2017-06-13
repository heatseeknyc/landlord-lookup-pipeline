#!/bin/sh -ue
#
# One-off script to dedup the HPD contacts file.
#
srcfile='stage/incoming/hpd/contact.csv'
dstfile='stage/xtracted/hpd/contact.csv'
sort $srcfile | uniq > $dstfile 
