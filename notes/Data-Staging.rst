
...

    stage/registrations.txt
    stage/contacts-dedup.txt
    stage/taxbills-latest.csv
    stage/dhcr_tuples.csv


(1) HPD registrations + contacts

These just require unpacking, deduping + renaming.

    cd stage
    unzip Registrations20161101.zip
    python ../bin/dedup.py < RegistrationContact20161031.txt > contacts-dedup.txt
    ln -s Registration20161031.txt registrations.txt

Also, make a note the YYYYMMDD part of the registrations file; which we'll need in Step X. 

(2) Taxbills


(3) DHCR tuples


