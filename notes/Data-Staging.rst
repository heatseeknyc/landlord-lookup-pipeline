
Notes about the "data staging" step, by which is meant the process of taking raw data files you've just obtained from their external sources (as described in the 'Data-Provenance.rst' note), and unpacking, renaming, and (lightly) processing them in such a way that they can be fed into the import scripts (i.e. loaded into the postgres instance). 

Basically the idea is that we want to end up with the following 5 CSV(-like) files:

    stage/registrations.txt
    stage/contacts-dedup.txt
    stage/taxbills-latest.csv
    stage/dhcr_tuples.csv
    stage/pluto-latest.csv

Which our 'bin/import-rawdata.sh' script can act on directly.


(1) + (2) HPD registrations + contacts

These just require unpacking, deduping + renaming.

    cd stage
    unzip Registrations20161101.zip
    python ../bin/dedup.py < RegistrationContact20161031.txt > contacts-dedup.txt
    ln -s Registration20161031.txt registrations.txt

Also, make a note the YYYYMMDD part of the registrations file; which we'll need in Step X. 


(3) Taxbills

The processing on the raw taxbills scrape is a bit more complex; after uncompressing, 
we need to select what appeas to bthe most recent ownership record for each BBL (containing
at least an "owner name" field), and emit a new CSV that's 1-to-1 between these records 
and BBLs (narrowing out file from about 56M rows to just over 1M in the process).

The script takes a while to run, but it goes like this:

    cd ..
    gunzip stage/rawdata.csv.gz
    python -m taxbills --infile=stage/rawdata.csv --outfile=stage/taxbills-latest.csv


(4) DHCR tuples

The data we have access dates from 2013 (and could use updating).  Here's the top-level location: 

    https://github.com/clhenrick/dhcr-rent-stabilized-data/tree/master/csv

Because the raw file is somewhat big, GitHub creates a special location for it, which has changed over time.  Here's the current directly accessible URL:

    cd stage
    curl -O https://raw.githubusercontent.com/clhenrick/dhcr-rent-stabilized-data/master/csv/dhcr_all_geocoded.csv

Once available, the file needs to be filtered before loading:

    cd ..
    bin/filter-dhcr.sh


(5) MAPPluto

tba
