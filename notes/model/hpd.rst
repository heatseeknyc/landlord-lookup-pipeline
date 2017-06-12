Notes about the *hpd* data model.

Let's start from the tables in the 'push' schema, which are still aligned 
very closely with the flat files they were loaded from (upto BBL/BIN normalization): 

    select count(*) from push.hpd_registration; 161747
    select count(*) from push.hpd_contact; 648875

