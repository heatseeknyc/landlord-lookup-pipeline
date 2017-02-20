#!/bin/bash -ue
#
# Unpack the Pluto zip, and get rid of the unsighly intermediate directory.
# Specific to 16v2.  As with all things Pluto, the name (or presence of) this 
# intermediate directory may well change in future versions, and so this script
# will need to be refactored accordingly.
#
tempdir='stage/unpack/pluto-temp'
unzip stage/incoming/pluto.zip '*.csv' -d $tempdir 
mv $tempdir/BORO_zip_files_csv  stage/unpack/pluto
rm -r $tempdir 
