#!/bin/sh -ue

bin/dopg.py -f sql/flat-pluto.sql
bin/dopg.py -f sql/flat-dob.sql
bin/dopg.py -f sql/flat-hpd.sql
bin/dopg.py -f sql/flat-acris.sql
bin/dopg.py -f sql/flat-stable.sql
bin/dopg.py -f sql/flat-misc.sql

