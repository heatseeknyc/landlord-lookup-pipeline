Notes about the DOB Permits dataset (June 2017)


Overview
--------

   select count(*) from push.dob_permit;                  745156
   select count(distinct(bbl,bin)) from push.dob_permit;  123865
   select count(distinct(bbl)) from push.dob_permit;      114378 

All BBLs/BINs in the permits dataset are valid and non-degenerate (so there are no "million" BINs).


job_id
------

    min(job_id),max(job_id) = (100052194,540129582)

