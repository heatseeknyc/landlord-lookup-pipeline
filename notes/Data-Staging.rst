
Notes about the "data staging" step, by which is meant the process of taking raw data files you've just obtained from their external sources (as described in the 'Data-Provenance.rst' note), and unpacking, renaming, and (lightly) processing them in such a way that they can be fed into the import scripts (i.e. loaded into the postgres instance). 

Basically the idea is that we want to end up with the following 5 CSV(-like) files:

    stage/registrations.txt
    stage/contacts-clean.txt
    stage/taxbills-latest.csv
    stage/dhcr_tuples.csv
    stage/pluto-latest.csv

Which our 'bin/import-rawdata.sh' script can act on directly.

PLEASE NOTE: The instructions in this writeup are in reference to external data sources in their current (2016 Q4) shape.  In the future, these external sources -- if they are still available -- are likely to mutate slightly (e.g. in regard to file names and archive structure, etc).  So you may have to adapt these instructions, accordingly. 


(1) + (2) HPD registrations + contacts

These just require the following steps: 
- first unpacking from the zip
- renaming one of the files (the registrations file)
- performing a dedup step on the other file (the contacts file), outputing to a new file
- then (most likely) performing a (quick) manual cleanup step on the newly dedup'd contacts file. 

Which goes like this:

    cd stage
    unzip Registrations20161101.zip
    ln -s Registration20161031.txt registrations.txt
    ln -s RegistrationContact20161031.txt contacts-raw.txt
    python -m apps.contacts --srcdir=stage

So the output files will be:

    stage/registrations.txt
    stage/contacts-clean.txt
    stage/contacts-rejected.txt

As the suffices on the contacts files imply, the "-clean" file is the one that will be loaded; the "-rejected" file should contain a (very small) number o lines rejected as unfit for loading.

BTW, make a note the YYYYMMDD part of the registrations file; it's basically the "as-of" date of the HPD snapshot.



(3) Taxbills

The processing on the raw taxbills scrape requires an algorithm step (in which we select 
what appears to bthe most recent ownership record for each BBL, each containing at least 
an "owner name" field), and emit a new CSV that's 1-to-1 between these records 
and BBLs  -- narrowing out file from about 56M rows to just over 1M in the process).

Which goes like this:

    cd ..
    gunzip stage/rawdata.csv.gz
    python -m apps.taxbills --srcdir=stage

It takes about 4-5 minutes to run, and, given a source directory, references both
input files and output files from fixed locations relative to that directory. 

It takes about 4-5 minutes to run and, references the input input file relative 
to the given source directory, and outputs to a fixed location:

    stage/taxbills-latest.csv


(4) DHCR tuples

The data we have access dates from 2013 (and could use updating).  Here's the top-level location: 

    https://github.com/clhenrick/dhcr-rent-stabilized-data/tree/master/csv

Because the raw file is somewhat big, GitHub creates a special location for it, which has changed over time.  Here's the current directly accessible URL:

    cd stage
    curl -O https://raw.githubusercontent.com/clhenrick/dhcr-rent-stabilized-data/master/csv/dhcr_all_geocoded.csv

Once available, the file needs to be filtered before loading:

    cd ..
    bin/filter-dhcr.sh

Which is hard-coded to expect 'stage' as the directory to find the raw input file,
and outputs to

    stage/dhcr_tuples.csv


(5) MAPPluto

First we unpack the 

Which might go like this:

    mkdir stage/pluto
    unzip nyc_pluto_16v2%20.zip -d /var/tmp
    mv /var/tmp/BORO_zip_files_csv/\*.csv stage/pluto
    ls stage/pluto/
    BK.csv  BX.csv  MN.csv  QN.csv  SI.csv
    python -m apps.pluto --srcdir=stage

It takes about 40 seconds to run and, like the taxbills script, references the input 
input files relative to the given source directory, and outputs to a fixed location:

    stage/pluto-latest.csv


