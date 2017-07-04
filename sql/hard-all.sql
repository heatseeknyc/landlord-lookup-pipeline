--
-- The "hard" schema contains all the tables accessed by the REST API,
-- with appropriate keys indexed (and just those columns indexed that 
-- we'll do ordered searches on).
--

begin;

drop table if exists hard.property_summary cascade;
create table hard.property_summary as
select * from meta.property_summary;
create index on hard.property_summary(bbl);
create index on hard.property_summary(bbl,bin);

drop table if exists hard.contact_info cascade;
create table hard.contact_info as
select * from meta.contact_info;
create index on hard.contact_info(contact_id);
create index on hard.contact_info(bbl);
create index on hard.contact_info(bbl,bin);

drop table if exists hard.pluto_building cascade;
create table hard.pluto_building as
select * from push.pluto_building; 
create index on hard.pluto_building(bbl);
create index on hard.pluto_building(doitt_id);

drop table if exists hard.taxlot cascade;
create table hard.taxlot as
select * from meta.taxlot;
create index on hard.taxlot(bbl);

commit;

