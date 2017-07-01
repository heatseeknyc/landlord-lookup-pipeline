Notes about the ACRIS raw files + data model.

Raw Files
---------

         124     9K acris/control.csv
  18,413,390  1218M acris/legal.csv
  14,051,501  1260M acris/master.csv
  37,779,536  3566M acris/party.csv
  70,244,551  6043M total


  select count(*) from push.acris_legal;   18,413,389
  select count(*) from push.acris_master;  14,046,595
  select count(*) from push.acris_party;   37,779,535


Note that 'master' is short some 4905 at this point; these are the rows that
were found to have one of the 749 multiply-occuring docid's.  So omitting these
rows (considering them to be 'anomolous' for the time being) leaves us with
docid as as primary key for that table.


push.acris_deed_history
-----------------------


select bbl,count(*) from p1.acris_deedhist_tidy group by bbl order by count(*) desc limit 30;
    bbl     | count 
------------+-------
 1010090037 | 17290
 1010061302 | 12263
 2039299999 |  6746
 2039379999 |  5243
 2039389999 |  4587
 2039439999 |  4131
 2039629999 |  3775
 1010061303 |  2163
 3000000000 |  2004
 4000000000 |  1651
 1010090039 |  1270
 1010061304 |   992
 2000000000 |   648
 1000000000 |   438
 3045210019 |   340



acris_buyer
-----------

    select count(*) from p1.acris_buyer;            5813978
    select count(distinct bbl) from p1.acris_buyer;  988595

    select bbl,count(*) from p1.acris_buyer group by bbl order by count(*) desc limit 30;
        bbl     | count 
    ------------+-------
     2039299999 |  9037
     2039379999 |  7041
     2039389999 |  6132
     2039439999 |  5568
     2039629999 |  4917
     1010061302 |  4080 - not in pluto - hilton related
     3000000000 |  2983
     4000000000 |  2362
     2000000000 |  1020
     3045210019 |   595
     1010090037 |   531 - 102 WEST 57 STREET | SHAFRANSKY, RENEE A - also hilton related
     1008560009 |   442
     3007060024 |   405
     3007100001 |   397
     3006830001 |   389
     3006950001 |   389
     3006870001 |   389
     3006790001 |   389
     3006910001 |   389
     3007060001 |   389
     3006910044 |   388
     3007060101 |   382


     select bbl,docid,count(distinct date_filed) from p1.acris_buyer group by bbl,docid having count(distinct date_filed) > 1; (empty) 


     select count(*) from (
        select bbl,date_filed,count(distinct docid) from p1.acris_buyer group by bbl,date_filed having count(distinct docid) > 1
     ) as x; 151109


As one might expect - sometimes there are many 

     select bbl,date_filed,count(distinct docid) 
     from p1.acris_buyer group by bbl,date_filed having count(distinct docid) > 1 
     order by count(distinct docid) desc;

    bbl     | date_filed | count 
------------+------------+-------
 2045080023 | 1971-10-20 |   144
 1008750025 | 1970-07-28 |   124
 1015190059 | 1970-07-30 |   108
 1005720034 | 1970-07-29 |    89
 1010061302 | 2004-07-04 |    66
 1010061302 | 2004-12-09 |    60
 2039299999 | 1986-06-18 |    59
 1010061302 | 2004-12-06 |    54
 1008400071 | 1998-01-14 |    50
 1014240041 | 1971-04-15 |    50
 1014240041 | 1971-04-19 |    50
 2039379999 | 1986-06-18 |    49



Yields about 5-6 BBLs per day with 2 or more docids (out of around 400 transfers per day, on average):

     select bbl,date_filed,count(distinct docid) 
     from p1.acris_buyer group by bbl,date_filed having count(distinct docid) > 1 
     order by date_filed desc;
              
Of these, 5-10 per month with 3 or more docids (50-100 per year)
Avering 25 per year with 5 or more sicne 2005 -- tending to decrease 


    select count(*) from p1.acris_daily;                 3336782
    select count(*) from p1.acris_daily where total = 1; 3185673
    select count(*) from p1.acris_daily where total > 1;  151109    - about 4.5%

    select count(*) from p1.acris_latest; 988595
    select count(*) from p1.acris_latest where total = 1; 962610
    select count(*) from p1.acris_latest where total > 1;  25985    - about 2.7%
    select count(*) from p1.acris_latest where total > 2;   2968
    select count(*) from p1.acris_latest where total > 5;    262

Counts for ``acris_latest`` per BBL/total will be the same; in addition we have: 

    select count(*) from p1.acris_latest where date_part('year',date_filed) = 2017;               25860
    select count(*) from p1.acris_latest where date_part('year',date_filed) = 2017 and total = 1; 25389
    select count(*) from p1.acris_latest where date_part('year',date_filed) = 2017 and total > 1;   471

So in the last 5 months, only about 1.4% of purchases have multiple docids per date. 
Multiple buyers (per docid) is a different story:

  select count(*) from p1.acris_latest; 988595
  select count(*) from p1.acris_latest where count_docid = 1; 962610
  select count(*) from p1.acris_latest where count_docid > 1;  25985
  select count(*) from p1.acris_latest where count_buyer = 1; 526220
  select count(*) from p1.acris_latest where count_buyer > 1; 462375
  select count(*) from p1.acris_latest where count_buyer = 2; 385537  - around 40.x% 
  select count(*) from p1.acris_latest where count_buyer = 3;  48461  - around  5.x% 
  select count(*) from p1.acris_latest where count_buyer = 4;  15826  - around  1.7% 
  select count(*) from p1.acris_latest where count_buyer = 5;   3816  - around   .4%
  select count(*) from p1.acris_latest where count_buyer > 5;   8735  - around   .9%

  select * from p1.acris_latest where bbl = 4109360245;
      bbl     |       max        | date_filed | total 
  ------------+------------------+------------+-------
   4109360245 | 2017053000585001 | 2017-05-31 |     1

  select * from p1.acris_daily where bbl = 4109360245;
      bbl     |       max        | date_filed | total 
  ------------+------------------+------------+-------
   4109360245 | 2017053000585001 | 2017-05-31 |     1

  select * from p1.acris_buyer where bbl = 4109360245;
    bbl     |      docid       | amount | percentage | date_filed |        name         |     address1      |    ...(omitted) 
  ------------+------------------+--------+------------+------------+---------------------+-------------------+---
   4109360245 | 2017053000585001 | 475000 |        100 | 2017-05-31 | GIBBS, YATTA JEROME | 110-44 197 STREET |   
   4109360245 | 2017053000585001 | 475000 |        100 | 2017-05-31 | GIBBS, FRANK  L     | 110-44 197 STREET |  



``coop-ism``

    select count(*) from (
        select bbl,count(distinct unit) from p1.acris_history group by bbl having count(distinct unit) > 1
    ) as x; 21833

