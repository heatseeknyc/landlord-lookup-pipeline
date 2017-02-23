#!/bin/bash -ue

destdir='stage/unpack/buildings'
echo "buildings to $destdir/ .."
unzip -q stage/incoming/buildings.zip -d $destdir
