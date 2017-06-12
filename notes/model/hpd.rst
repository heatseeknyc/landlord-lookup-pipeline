Notes about the *hpd* data model.

Let's start from the tables in the 'push' schema, which are still aligned 
very closely with the flat files they were loaded from (upto BBL/BIN normalization): 

    select count(*) from push.hpd_building; 298251
    select count(*) from push.hpd_registration; 161747
    select count(*) from push.hpd_contact; 648875

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



HPD v. DOB building identifiers
-------------------------------

Recall that BIN is present only in ``hpd_building`` and ``hpd_registration``.
And at least it's always non-null in each:

    select count(*) from push.hpd_registration where bin is null; 0
    select count(*) from push.hpd_building where bin is null; 0

We would expect it to be at least an alternte key in ``hpd_building``, but unforunately this is far from the case:

    select count(*),sum(total) from (
        select bin,count(*) as total from push.hpd_building group by bin having count(*) > 1 order by count(*)
    ) as x; (2778,6445)

The analogous query applied to ``id`` returns 0 rows -- so at least it's unique in that table.

Recall that ``hpd_registration`` is a ledger of registration events (not buildings), so we won't expect its identifiers to be unique. 
It'd be at least comforting if BIN and HPD id were 1-to-1 in this table; and indeed we can confirm that this is the case, 
as the following query has empty row count:

    select building_id,count(distinct bin) from push.hpd_registration group by building_id having count(distinct bin) > 1; 

This leaves open the question of to what extent the identifiers overlap across the two tables.

(to be continued)

