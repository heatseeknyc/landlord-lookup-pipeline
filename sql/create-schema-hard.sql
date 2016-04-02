--
-- The "hard" schema contains all the tables accessed by the REST API,
-- with appropriate keys indexed (and just those columns indexed that 
-- we'll do ordered searches on).
--

begin;

drop schema if exists hard cascade;
create schema hard;

create table hard.registrations as 
select * from push.registrations;

create table hard.contact_info as
select * from meta.contact_info;

create table hard.property_summary as
select * from meta.property_summary;

grant usage on schema hard to readuser;
grant select on all tables in schema hard to readuser;

commit;

