begin;

create table push.pluto_taxlot as
select * from core.pluto_taxlot_remix;
create index on push.pluto_taxlot(bbl);

create table push.pluto_building as
select * from core.pluto_building;
create index on push.pluto_building(bbl,bin);

create table push.pluto_building_canonical as
select * from core.pluto_building_canonical;
create index on push.pluto_building_canonical(bbl,bin);

-- Yes, these next two statements just copy existing tables from the 'flat' schema. 
-- But the tables are small, and it's convenient to have everything together here 
-- in the 'push' schema.

create table push.pluto_refdata_bldgclass as
select * from flat.pluto_refdata_bldgclass;
create index on push.pluto_refdata_bldgclass(tag);

create table push.pluto_refdata_landuse as
select * from flat.pluto_refdata_landuse;
create index on push.pluto_refdata_landuse(tag);

commit;

