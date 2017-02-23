#!/bin/bash -ue
#
# Unpack just the shapefile data files from the 5 mappluto zips.  (Note that 
# this corresponds to the set of files with extensions of exactly 3 lower case 
# letters, per the globbing pattern below).
#
# Specific to 16v2.  As with all things Pluto, the layout and naming conventions 
# for these files may well change in future Pluto releases, and so this script
# will need to be refactored accordingly.
#

ver='16v2'
destdir='stage/unpack/pluto'
echo "mappluto $ver to $destdir/ .."
unzip -q stage/incoming/pluto/mn_mappluto_$ver.zip 'MNMapPLUTO.[a-z][a-z][[a-z]' -d $destdir 
unzip -q stage/incoming/pluto/bk_mappluto_$ver.zip 'BKMapPLUTO.[a-z][a-z][[a-z]' -d $destdir 
unzip -q stage/incoming/pluto/bx_mappluto_$ver.zip 'BXMapPLUTO.[a-z][a-z][[a-z]' -d $destdir 
unzip -q stage/incoming/pluto/qn_mappluto_$ver.zip 'QNMapPLUTO.[a-z][a-z][[a-z]' -d $destdir 
unzip -q stage/incoming/pluto/si_mappluto_$ver.zip 'SIMapPLUTO.[a-z][a-z][[a-z]' -d $destdir 
