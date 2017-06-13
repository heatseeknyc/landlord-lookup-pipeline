Notes about the HPD raw files + data model.

Raw Files
---------

Line counts + file sizes (June 2017):

    311,066    40M  hpd/building.csv
  1,033,312    97M  hpd/complaint.csv
    649,623    56M  hpd/contact.csv   -- around 47k of which are dups 
     69,886     7M  hpd/legal.csv
    164,893    17M  hpd/registration.csv
  2,185,731   850M  hpd/violation.csv
  4,414,511  1067M  total




Relationships
-------------

Let's start from the tables in the 'push' schema, which are still aligned 
very closely with the flat files they were loaded from (upto BBL/BIN normalization): 

    table_name         count    keys (primary; secondary) 
   ------------------
    hpd_building       298251   hpd_building_id; BBL, BIN                   | entity information for buildings
    hpd_registration   161747   registration_id; BBL, BIN, HPDid  | registration group <=> building -or- taxlot
    hpd_contact        648875   registration_id, contact_id                 | contacts per registration group
    hpd_complaint;    1014313   complaint_id; BBL, HPDid
    hpd_violation;    2104236   violation_id; BBL, HPDid, registrtion_id, nov_id
    hpd_legal;          69474   litigation_id; BBL, HPDid

And this derived analytical view, which we'll explain later:

    select count(*) from push.hpd_bin_xref; 305360  


hpd_building
------------

Represents "buildings under HPD jurisdiction" - in theory, all residential buildings.

    select * from push.hpd_building limit 3;

     id |    bbl     |   bin   | program | dob_class_id | legal_stories | legal_class_a | legal_class_b | lifecycle | status_id 
    ----+------------+---------+---------+--------------+---------------+---------------+---------------+-----------+-----------
      1 | 1004340001 | 1005769 | PVT     |            1 |             5 |             7 |             0 | Building  |         1
      2 | 1013480023 | 1039972 | PVT     |           24 |            20 |             0 |             0 | Building  |         1
      3 | 1013670001 | 1040460 | PVT     |            5 |            39 |           603 |             0 | Building  |         1


Notes: 
  - ``bbl`` and ``bin`` in the usual sense
  - ``id`` is the HPD building ID


hpd_registration
----------------

First note that registration_id is -not- a primary key:

     select count(*) from push.hpd_registration; 161747
     select count(distinct id) from push.hpd_registration; 153751

In the 'push' schema we've dropped the address fields, restrict only to 
fields that convey essential relationship information: 

    select * from push.hpd_registration limit 3;
       id   |    bbl     | building_id |   bin   | last_date  |  end_date  
    --------+------------+-------------+---------+------------+------------
     300178 | 3009517501 |      133581 | 3019673 | 2013-12-13 | 2014-09-01
     300521 | 3063750009 |      144850 | 3166888 | 2016-08-22 | 2017-09-01
     366743 | 3074330034 |      197626 | 3203889 | 2016-11-16 | 2017-09-01

A couple of notes as to what we have here:
  - ``id`` is the *registration id* 
  - ``bbl`` and ``bin`` in the usual sense
  - ``building_id`` is the HPD building ID


hpd_contact
-----------

   select count(*) from push.hpd_contact; 648875
   select count(distinct id) from push.hpd_contact; 602645
   select count(*),sum(total) from (
       select id,count(*) as total from push.hpd_contact group by id having count(*) > 1
   ) as x; (293,46523)

    select id,count(*) as total from push.hpd_contact group by id having count(*) > 1 order by count(*) desc limit 40;
        id    | total 
    ----------+-------
     91174103 |  1448
     91174113 |  1448
     91174104 |  1448
     91174106 |  1448
     91174105 |  1448
     91254705 |   894
     91254713 |   894
     91254703 |   894
     91254706 |   894
     91254704 |   894
     91323603 |   698
     91323606 |   698



HPD v. DOB building identifiers
-------------------------------




Recall that BIN is present only in ``hpd_building`` and ``hpd_registration``.  
And that ``hpd_registration`` is a ledger of registration events (not buildings), 
so we won't expect its identifiers to be unique.  That said, we'd like to investigate 
whether we can be sure of some basic assumpetions about each table.  

At least both identifiers are always non-null in each table: 

    select count(*) from push.hpd_registration where bin is null; 0
    select count(*) from push.hpd_registration where building_id is null; 0
    select count(*) from push.hpd_building where bin is null; 0
    select count(*) from push.hpd_building where id is null; 0

But let's see what's going on with ``hpd_building``, where we would expect ``id`` and ``bin`` 
to be alternate keys.  Unfortunately this doesn't appear to be the case.  Let's look at ``hpd_building`` first: 

    select count(*) from push.hpd_building;            298251
    select count(distinct id) from push.hpd_building;  298251
    select count(distinct bin) from push.hpd_building; 294574
    select count(*),sum(total) from (
        select bin,count(distinct id) as total from push.hpd_building group by bin having count(distinct id) > 1 
    ) as x; (2778,6445)

Or 2778 BINs occuring multiply across 6445 rows.  And over in ``hpd_registration`` it's the same story: 

    select count(distinct building_id) from push.hpd_registration; 161746
    select count(distinct bin) from push.hpd_registration;         159335
    select count(*),sum(total) from (
        select bin,count(distinct building_id) as total from push.hpd_registration group by bin having count(distinct building_id) > 1
    ) as x; (1125,3536)

That is, 1125 BINs occuring multiply across 6445 rows.  Here's a brief survey of the worst offenders in each table:

    select bin,count(distinct id) from push.hpd_building group by bin order by count(distinct id) desc limit 5;
       bin   | count 
    ---------+-------
     4171984 |    28
     4147370 |    24
     4902977 |    22
     4147320 |    13
     4432142 |    13

    select bin,count(distinct building_id) from push.hpd_registration group by bin order by count(distinct building_id) desc limit 10;
       bin   | count 
    ---------+-------
     4445478 |   102
     4454129 |    29
     4171984 |    28
     4147370 |    24
     4448352 |    19




The analogous query applied to ``id`` returns 0 rows -- so at least it's unique in that table.

It'd be at least comforting if BIN and HPD id were 1-to-1 in this table; and indeed we can confirm that this is the case, 
as the following query has empty row count:

    select building_id,count(distinct bin) from push.hpd_registration group by building_id having count(distinct bin) > 1; 

This leaves open the question of to what extent the identifiers overlap across the two tables.

    select count(*) from temp.bin_hpd_to_dob;                           299265
    select count(*) from temp.bin_hpd_to_dob where bin_bld is not null; 291796
    select count(*) from temp.bin_hpd_to_dob where bin_reg is not null; 158210
    select count(*) from temp.bin_hpd_to_dob where bin_reg = bin_bld;   150741 
    select count(*) from temp.bin_hpd_to_dob where bin_bld != bin_reg;       0

    select count(*) from temp.bin_dob_to_hpd;                           299233
    select count(*) from temp.bin_dob_to_hpd where hpd_bld is not null; 291796
    select count(*) from temp.bin_dob_to_hpd where hpd_reg is not null; 158210
    select count(*) from temp.bin_dob_to_hpd where hpd_bld = hpd_reg;   150741
    select count(*) from temp.bin_dob_to_hpd where hpd_bld != hpd_reg;      32

Of special interest are the outlier sets:

    select count(*) from temp.bin_dob_to_hpd where hpd_bld is null;       7437
    select count(*) from temp.bin_hpd_to_dob where bin_bld is null;       7469

Upshot being there are some 7400+ BINs -uniquely- identifiable in ``hpd_registrations`` that aren't present in ``hpd_building``.




violation + complaint
---------------------

    hpd_complaint  | 1014313 | complaint_id; BBL, hpd_building_id
    hpd_violation  | 2104236 | violation_id; BBL, hpd_building_id,

    select count(*) from push.hpd_complaint where id is null; 0
    select count(*) from push.hpd_violation where id is null; 0
    select count(distinct id) from push.hpd_violation;  2104236
    select count(distinct id) from push.hpd_complaint;  1014313


hpd_legal
---------

    hpd_legal;          69474   BBL, hpd_building_id, 

    select count(distinct id) from push.hpd_legal; 69474

