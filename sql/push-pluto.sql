begin;

drop table if exists push.pluto_taxlot cascade; 
create table push.pluto_taxlot as
select * from core.pluto_taxlot_remix;
create index on push.pluto_taxlot(bbl);

drop view if exists push.pluto_taxlot_tidy cascade; 
create view push.pluto_taxlot_tidy as
select 
    bbl, address, owner_name, 
    bldg_class as class, land_use as land, year_built as year, 
    units_total as utot, units_res as ures, num_floors as numfl, 
    bldg_count, bbl2qblock(bbl) as qblock
from push.pluto_taxlot;


drop table if exists push.pluto_building cascade; 
create table push.pluto_building as
select * from  core.pluto_building;;
create index on push.pluto_building(bbl);
create index on push.pluto_building(bin);
create index on push.pluto_building(bbl,bin);

drop materialized view if exists push.pluto_building_count cascade; 
create materialized view push.pluto_building_count as
select bbl, count(*) as total, count(distinct bin) as building
from push.pluto_building group by bbl; 

-- A counting table by (BBL,BIN) with the restriction that both columns 
-- are non-null.  Currently excludes the single tuple (NULL,0) in 16v2.
-- Yields 1081156 tuples.
drop table if exists push.pluto_keytup cascade; 
create table push.pluto_keytup as
select bbl, bin, count(*) as total 
from push.pluto_building where bbl is not null and bin is not null
group by bbl, bin;
create index on push.pluto_keytup(bbl);
create index on push.pluto_keytup(bin);
create index on push.pluto_keytup(bbl,bin);


-- These next two statements just copy existing tables from the 'flat' schema. 
-- But the tables are small, and it's convenient to have everything together here 
-- in the 'push' schema.

drop table if exists push.pluto_refdata_bldgclass cascade; 
create table push.pluto_refdata_bldgclass as
select * from flat.pluto_refdata_bldgclass;
create index on push.pluto_refdata_bldgclass(tag);

drop table if exists push.pluto_refdata_landuse cascade; 
create table push.pluto_refdata_landuse as
select * from flat.pluto_refdata_landuse;
create index on push.pluto_refdata_landuse(tag);

drop table if exists push.pluto_refdata_control cascade;
create table push.pluto_refdata_control as
select * from core.pluto_refdata_control;
create index on push.pluto_refdata_landuse(tag);

commit;


