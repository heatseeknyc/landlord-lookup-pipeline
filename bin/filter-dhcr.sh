#!/bin/bash -ue
awk -F ',' 'BEGIN { OFS = "," }{print $18,$19}' stage/dhcr_all_geocoded.csv > stage/dhcr_building_tuples.csv
