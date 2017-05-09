--
-- The "hard" schema contains all the tables accessed by the REST API,
-- with appropriate keys indexed (and just those columns indexed that 
-- we'll do ordered searches on).
--

begin;

create table hard.property_summary as
select * from meta.property_summary;

create table hard.contact_info as
select * from meta.contact_info;

create table hard.pluto_building as
select * from push.pluto_building; 

--
-- Deprecated for the time being.
--
-- create table hard.registrations as 
-- select * from push.registrations;

commit;

