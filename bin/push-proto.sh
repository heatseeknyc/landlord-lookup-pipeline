#!/bin/sh -ue
#
# Push datasets from the source control 'proto' dir to its image
# under the staging dir.  Idea being that the 'stage' location should 
# be ultimately configuratble (even if it isn't yet) and in any case 
# logically independent from the source tree. 
#

STAGE=stage

rsync -avz proto/ $STAGE/0-proto 

