--
-- The "hard" schema contains all the tables accessed by the REST API,
-- with appropriate keys indexed (and just those columns indexed that 
-- we'll do ordered searches on).
--
-- Row counts are for July 2017.

begin;

-- 644,971 rows
drop table if exists hard.contact_info cascade;
create table hard.contact_info as
select * from meta.contact_info;
create index on hard.contact_info(contact_id);
create index on hard.contact_info(bbl);
create index on hard.contact_info(bbl,bin);

-- 1,238,985 rows
drop table if exists hard.taxlot cascade;
create table hard.taxlot as select * from meta.taxlot;
create index on hard.taxlot(bbl);

-- 1,186,668 rows
drop table if exists hard.building cascade;
create table hard.building as select * from meta.building;
create index on hard.building(bbl);
create index on hard.building(bin);
create index on hard.building(bbl,bin);

-- These we simply copy over so they're all in the hard schema.
drop table if exists hard.pluto_refdata_bldgclass cascade;
create table hard.pluto_refdata_bldgclass as
select * from push.pluto_refdata_bldgclass;
create index on hard.pluto_refdata_bldgclass(tag);

drop table if exists hard.pluto_refdata_landuse cascade;
create table hard.pluto_refdata_landuse as
select * from push.pluto_refdata_landuse;
create index on hard.pluto_refdata_landuse(tag);

-- And this one from the moni schema.
drop table if exists hard.label_status cascade; 
create table hard.label_status as select * from omni.label_status;
create index on hard.label_status(status);

commit;

