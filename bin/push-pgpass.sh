#!/bin/bash -ue
cp config/pgpass.txt ~postgres/.pgpass
chown postgres ~postgres/.pgpass
chmod 600 ~postgres/.pgpass
