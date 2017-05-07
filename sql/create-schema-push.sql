--
-- The 'push' schema presents full-table versions of the corresponding 
-- views in the 'core' schema.  So yes, basically this amounts to just
-- renaming columns by this stage (minus a few we're droppping); but 
-- they'll also have a different index structure, and we'll have all 
-- the data we need together in one place. 
--
-- There's also a new table introduce for contact_type search order, 
-- defined below.
--

begin;

drop schema if exists push cascade;
create schema push;

create table push.pluto_taxlot as
select * from core.pluto_taxlot_remix;

create table push.pluto_building as
select * from core.pluto_building;

create table push.pluto_building_primary as
select * from core.pluto_building_primary;

-- All columns except street_code, block, lot; and crucially, indexed by BBL.
create table push.registrations as
select 
  id, bbl, building_id, boro_id, house_number, house_number_low, house_number_high,
  street_name, zip, bin, cb_id, last_date, end_date
from core.registrations;

create table push.contacts as
select * from core.contacts;

--
-- A reference table specifying pre-defined sorting order for contact_type fields. 
--
-- contact_type fields fuzzily ranked in order of importance / frequency.
-- The list contains all 9 fields observed to occur in the Dec 2015 dataset 
-- (which might well change in future datasets, but this column seems 
-- relatively well-behaved compared to others, thus far).
-- 
-- The idea is that "owner-ish" designations appear closer to the top, and 
-- "manager/agent" fields appear closer to the bottom, and the "lessee" value
-- at the very bottom.
--

create table push.contact_rank ( 
    id integer,
    contact_type text
);

insert into push.contact_rank (id,contact_type) values 
    (1,'CorporateOwner'),
    (2,'IndividualOwner'),
    (3,'JointOwner'),
    (4,'HeadOfficer'),
    (5,'Officer'),
    (6,'Shareholder'),
    (7,'SiteManager'),
    (8,'Agent'),
    (9,'Lessee')
;

create table push.stable as
select * from core.stable;

commit;
