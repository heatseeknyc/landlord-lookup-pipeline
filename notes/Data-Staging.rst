
Notes about the "data staging" step, by which is meant the process of taking raw data files you've just obtained from their external sources (as described in the 'Data-Acquisition.rst' note), and unpacking, renaming, and (lightly) processing them in such a way that they can be fed into the import scripts (i.e. loaded into the postgres instance). 


1. Canonicalization
===================

In order to keep the subsequent steps as generic as possible (that is, independent of the particular naming styles of the newly acquired datasets, as they appear in the current moment), we first create symbolic links from "physical" names (i.e. the names of files in their freshly downloaded state) to canonical names that can be recognized by our scripts without further customization:: 

  ln -s 'Building Footprints.zip' buildings.zip
  ln -s nyc_pluto_16v2%20.zip pluto.zip
  ln -s rawdata-2016-june.csv.gz rawdata.csv.gz
  ln -s Registrations20161101.zip registrations.zip

Basically the idea is that we want to end up with the following 5 CSV(-like) files::

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
    python -m extract.contacts --srcdir=stage

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
    gunzip stage/rawdata-2016-june.csv.gz
    ln -s stage/rawdata-2016-june.csv state/rawdata.csv
    python -m extract.taxbills --srcdir=stage

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

TODO: describe process resulting in

    stage/pluto-latest.csv


(6) Building footprints

TODO: describe process resulting in

    stage/buildings-latest.csv

