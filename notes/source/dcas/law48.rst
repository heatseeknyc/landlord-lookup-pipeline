
Note about the DCAS Local Law 48 dataset.

First thing you notice is that the raw file contains many repeats on the BBL column:

   select count(*) from core.dcas_law48; 42370
   select count(distinct bbl) from core.dcas_law48; 15316

Apparently it's 3 different versions of (almost) the same information repeated throughout the file:

  select bbl,coordinates,address,parcel_name,agency,created,pluto from core.dcas_law48 order by bbl,created;
    bbl     |   coordinates   |           address           |          parcel_name           |            agency             |  created   | pluto 
  ------------+-----------------+-----------------------------+--------------------------------+-------------------------------+------------+-------
  1000030001 | 979906/195360   | BATTERY PARK                | BATTERY PARK                   | PARKS                         | 2011-12-15 | 
  1000030001 | 0979905/0195360 | BATTERY PARK                | BATTERY PARK                   | PARKS                         | 2013-12-11 | 13v1
  1000030001 | 979916/195328   | 10 BATTERY PARK             | BATTERY PARK                   | PARKS                         | 2015-12-14 | 15v1

Once you aggregate, you get a row count pretty close to what IPIS has (15937).
With some 642 orphans in neither PAD nore ACRIS:

  select count(*) from core.dcas_law48_count as a left join hard.taxlot as b on a.bbl = b.bbl where b.bbl is null; 642 

Or simply:

  select count(*) from omni.dcas_law48_orphan; 642

Many of these appear to be demapped lots since merged into much bigger lots e.g. for playgrounds, etc.
and in fact the vast majority are parts of the varous Blue Belt projects in SI.

There's also few outlier (high-numbered) lots: 

  select * from omni.dcas_law48_orphan where bbl2lot(bbl) > 500 order by bbl;
      bbl     |   latest   |   coordinates   |   address    |          parcel_name          | agency | easements 
  ------------+------------+-----------------+--------------+-------------------------------+--------+-----------
   1001531002 | 2013-12-11 | 0982690/0199487 | 280 BROADWAY | 280 BROADWAY-FLOORS 3-7       | DCAS   |         0
   2032578900 | 2015-12-14 | 0/0             |              | OLD LANE                      | DCAS   |         0
   3080228900 | 2013-12-11 | 0000000/0000000 |              | "VARKENS HOOK ROAD"           | DCAS   |         0
   5024500600 | 2011-12-15 | 0/0             | ESSEX DRIVE  | JEROME PARKER EDUC CAMPUS R43 | EDUC   |         0
   5069010510 | 2011-12-15 | 0/0             | VOGEL AVENUE | LEMON CREEK BLUEBELT          | DEP    |         0
  (5 rows)

The first one appears to be a condo unit DCAS has sold to itself in the building it also owns.


Missing
-------

It's apparently missing some city-owned properties:

  1003750059 - NYCHA building at 250 Broadway

