#!/bin/bash -ue
pg_user='demo'

echo '[fix] contact addresses...'
psql -U $pg_user -d hpd -f 'sql/fix-contact-addresses.sql'
echo '[fix] registration addresses...'
psql -U $pg_user -d hpd -f 'sql/fix-registration-addresses.sql'
echo '[fix] done.'
