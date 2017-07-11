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

General properties:
 - in general they occur multiply (max = 50)

In general they are many-to-1 with (BBL,BIN) pairs:
 - there can be up to the low hundreds (max 518) for a given BBL-BIN pair
 - but in general there's at most one (BBL,BIN) pair for a job_id 
 - Except for some 1825 Job IDs which have multiple (BBL,BIN) pairs 


Stats

   select count(distinct job_id) from push.dob_permit;
   select count(*) from (select job_id,count(distinct(bbl,bin)) as total from push.dob_permit group by job_id) as x where total > 1;  1773
   select count(*) from (select job_id,count(distinct(bbl,bin)) as total from push.dob_permit group by job_id) as x where total > 2;    52 


SQL

    select * from (
        select job_id,count(distinct(bbl,bin)) as total from push.dob_permit group by job_id
    ) as x order by total desc limit 20;
