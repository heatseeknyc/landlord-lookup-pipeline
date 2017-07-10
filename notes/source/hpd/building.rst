Notes about the "Buildings under HPD jurisdiction" dataset.



  select bbl,bin,count(distinct program) 
  from push.hpd_building where lifecycle = 'Building' 
  group by bbl,bin having count(distinct program) > 1 order by bbl;

      bbl     |   bin   | count 
  ------------+---------+-------
   1001420025 | 1083239 |     2
   1016560001 | 1084322 |     2
   2024400001 | 2091242 |     2
   2051350051 | 2093853 |     2
   3014420066 | 3038759 |     2
   3031370011 | 3071799 |     2
   4159260001 | 4459305 |     2
   5009550001 | 5113197 |     2
  (8 rows)


