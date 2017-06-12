Notes about the *hpd* data model.

Let's start from the tables in the 'push' schema, which are still aligned 
very closely with the flat files they were loaded from (upto BBL/BIN normalization): 

    select count(*) from push.hpd_building; 298251
    select count(*) from push.hpd_registration; 161747
    select count(*) from push.hpd_contact; 648875


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


hpd_registration
----------------

In the 'push' schema we've dropped the address fields, restrct only to 
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

