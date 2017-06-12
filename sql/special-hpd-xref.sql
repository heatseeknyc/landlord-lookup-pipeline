--
-- These intermediate views culminate in an analytical table useful to sorting out 
-- conflicts between DOB + HPD building identifiers across the various primary tables.  
--
-- We create a table at the end because (being an outer join on the 5 primary tables)
-- it would be way too slow when invoked as a view; so we'll blow some space + create 
-- a hard table.  But we'll at least drop the intermediate views in the end.
--
-- Row counts are for illustrative purposes, using the May 2017 datasets. 
--

begin;

drop materialized view if exists temp.hpd_bin_building cascade;
create materialized view temp.hpd_bin_building as 
select bin,count(distinct id) as total from push.hpd_building group by bin;
create index on temp.hpd_bin_building(bin); 
-- 294574 rows 

drop materialized view if exists temp.hpd_bin_registration cascade;
create materialized view temp.hpd_bin_registration as 
select bin,count(distinct building_id) as total from push.hpd_registration group by bin;
create index on temp.hpd_bin_registration(bin); 
-- 159335 rows

-- Unified counts of distinct HPD ids per BIN, across both table.
drop materialized view if exists temp.hpd_bin_count cascade;
create materialized view temp.hpd_bin_count as 
select
    coalesce(a.bin,b.bin) as bin, 
    a.total as tot_bld,
    b.total as tot_reg
from            temp.hpd_bin_building     as a
full outer join temp.hpd_bin_registration as b on a.bin = b.bin;
create index on temp.hpd_bin_count(bin); 
-- 300766 rows


--
-- Where BINs and HPD ids are 1-to-1, we create association rowsets for both tables.
--
create view temp.hpd_bin_building_distinct as
select a.bin, b.id as hpd_id
from      temp.hpd_bin_building  as a
left join push.hpd_building      as b on a.bin = b.bin
where a.total = 1;
-- 291796 rows 

create view temp.hpd_bin_registration_distinct as
select a.bin, b.building_id as hpd_id
from      temp.hpd_bin_registration  as a
left join push.hpd_registration as b on a.bin = b.bin
where a.total = 1;
-- 158210 rows 

-- And a unified view of the DOB <-> HPD mapping across both tables,
-- where this relationship is well-defined (that is, 1-to-1 in either table):
drop materialized view if exists temp.bin_hpd_to_dob cascade;
create materialized view temp.bin_hpd_to_dob as 
select
    coalesce(a.hpd_id,b.hpd_id) as hpd_id,
    a.bin as bin_bld,
    b.bin as bin_reg
from            temp.hpd_bin_building_distinct     as a
full outer join temp.hpd_bin_registration_distinct as b on a.hpd_id = b.hpd_id;
create index on temp.bin_hpd_to_dob(hpd_id);
-- 299265 rows

-- ... and the other way...
drop materialized view if exists temp.bin_dob_to_hpd cascade;
create materialized view temp.bin_dob_to_hpd as 
select
    coalesce(a.bin,b.bin) as bin ,
    a.hpd_id as hpd_bld,
    b.hpd_id as hpd_reg
from            temp.hpd_bin_building_distinct     as a
full outer join temp.hpd_bin_registration_distinct as b on a.bin = b.bin;
create index on temp.bin_dob_to_hpd(bin);
-- 299233 rows

commit;


/*
drop materialized view if exists push.hpd_xref_bin_1 cascade;
create materialized view push.hpd_xref_bin_1 as 
select 
    coalesce(a.id,b.building_id) as hpd_id, 
    a.bin as bin_bld, b.bin as bin_reg
from            push.hpd_building     as a 
full outer join push.hpd_registration as b on a.id = b.building_id; 
create index on push.hpd_xref_bin_1(hpd_id); 

-- A unified view of HPD id across complaints + violations 
-- Size = 159016 rows for May 2017.
drop materialized view if exists push.hpd_xref_bin_2 cascade;
create materialized view push.hpd_xref_bin_2 as 
select 
    coalesce(a.building_id,b.building_id) as hpd_id, 
    a.total as tot_com, b.total as tot_vio
from ( 
    select building_id,count(*) as total from push.hpd_complaint group by building_id) as a
full outer join (
    select building_id,count(*) as total from push.hpd_violation group by building_id) as b on a.building_id = b.building_id; 
create index on push.hpd_xref_bin_2(hpd_id); 

-- And this one will have a unified view of HPD id across complaint + violation + legal.
-- Size = 164980 rows for May 2017.
drop materialized view if exists push.hpd_xref_bin_3 cascade;
create materialized view push.hpd_xref_bin_3 as 
select 
    coalesce(a.hpd_id,b.building_id) as hpd_id,
    a.tot_com, a.tot_vio, b.total as tot_leg
from push.hpd_xref_bin_2 as a
full outer join (
    select building_id,count(*) as total from push.hpd_legal group by building_id) as b on a.hpd_id = b.building_id; 
create index on push.hpd_xref_bin_3(hpd_id); 

-- And this presents a unified view of HPD building ID, BIN (where present), 
-- and totals otherwise across all 5 primary sources.
-- Size = 309014 rows for May 2017.
drop table if exists push.hpd_xref_bin cascade;
create table push.hpd_xref_bin as 
select 
    coalesce(a.hpd_id,b.hpd_id) as hpd_id, 
    a.bin_bld, a.bin_reg,
    b.tot_com, b.tot_vio, b.tot_leg
from            push.hpd_xref_bin_1 as a 
full outer join push.hpd_xref_bin_3 as b on a.hpd_id = b.hpd_id; 
create index on push.hpd_xref_bin(hpd_id); 

-- Now let's drop those intermediate views, to reclaim space.
-- Note that the drop on view '2' will cascade to view '3'.
drop materialized view push.hpd_xref_bin_2 cascade;
drop materialized view push.hpd_xref_bin_1 cascade;

commit;
*/

