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


