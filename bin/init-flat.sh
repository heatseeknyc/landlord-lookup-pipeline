#!/bin/sh -ue

bin/dopq.py -f sql/flat-pluto.sql
bin/dopq.py -f sql/flat-dob.sql
bin/dopq.py -f sql/flat-hpd.sql
bin/dopq.py -f sql/flat-acris.sql
bin/dopq.py -f sql/flat-stable.sql
bin/dopq.py -f sql/flat-misc.sql

