#!/bin/sh -ue
#
# Push datasets from the source control 'proto' dir to its image
# under the staging dir.  Idea being that the 'stage' location should 
# be ultimately configuratble (even if it isn't yet) and in any case 
# logically independent from the source tree. 
#

STAGE=stage

mkdir $STAGE
mkdir $STAGE/0-proto
mkdir $STAGE/1-incoming
mkdir $STAGE/2-unpack
mkdir $STAGE/3-xtracted
mkdir $STAGE/4-special
mkdir $STAGE/export

