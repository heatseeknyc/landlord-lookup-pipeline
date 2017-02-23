#!/bin/bash -ue
#
# Unpack the Pluto zip, and get rid of the unsighly intermediate directory.
# Specific to 16v2.  As with all things Pluto, the name (or presence of) this 
# intermediate directory may well change in future versions, and so this script
# will need to be refactored accordingly.
#
destdir='stage/unpack/hpdreg'
mkdir $destdir
echo "registrations to $destdir .."
unzip -c stage/incoming/registrations.zip 'Registration20*.txt' > $destdir/Registration.txt
unzip -c stage/incoming/registrations.zip 'RegistrationContact*.txt' > $destdir/RegistrationContact.txt
