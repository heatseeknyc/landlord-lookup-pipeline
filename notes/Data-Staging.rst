
...



TODO: describe how to get rawfiles + place into staging dir.

  ln -s $stagepath stage
    bin/dedup.py stage/RegistrationContact20160229.txt > stage/contacts-dedup.txt
      cd stage
        ln -s Registration20160229.txt registrations.txt
          cd ..

          Also note the YYYYMMDD part of the registrations dump,
          which we'll need in Step 3.


