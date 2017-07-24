#!/bin/sh -ue

bin/dopg.py -q -f sql/core-pluto.sql
bin/dopg.py -q -f sql/core-dob.sql
bin/dopg.py -q -f sql/core-hpd.sql
bin/dopg.py -q -f sql/core-acris.sql
bin/dopg.py -q -f sql/core-stable.sql
bin/dopg.py -q -f sql/core-misc.sql

