
begin;

-- These intermediate views culminate in an analytical table useful to sorting out 
-- conflicts between DOB + HPD building identifiers across the various primary tables.  
-- Unfortunately it seems too slow when invoked as a view, so we'll blow some space + 
-- create a hard table.  We will at least drop the intermediate views in the end.
-- Size = 305360 rows for May 2017.
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
-- (Note that the drop on view '2' will cascade to view '3').
drop materialized view push.hpd_xref_bin_2 cascade;
drop materialized view push.hpd_xref_bin_1 cascade;

commit;

