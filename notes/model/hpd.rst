Notes about the *hpd* data model.

Let's start from the tables in the 'push' schema, which are still aligned 
very closely with the flat files they were loaded from (upto BBL/BIN normalization): 

    select count(*) from push.hpd_registration; 161747
    select count(*) from push.hpd_contact; 648875


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
  - ``bbl`` in the usual sense
  - ``building_id`` is the HPD building ID
  - ``bin`` is the DOB building identifier number 

