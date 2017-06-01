begin;

create table push.pluto_taxlot as
select * from core.pluto_taxlot_remix;

create table push.pluto_building as
select * from core.pluto_building;

create table push.pluto_building_canonical as
select * from core.pluto_building_canonical;

-- Yes, these next two statements just copy existing tables in-place.
-- But the tables are small, and it's convenient to have everything 
-- together in the 'push' schema.

create table push.pluto_refdata_bldgclass as
select * from flat.pluto_refdata_bldgclass;

create table push.pluto_refdata_landuse as
select * from flat.pluto_refdata_landuse;

commit;

