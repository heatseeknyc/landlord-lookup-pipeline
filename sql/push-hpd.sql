
begin;

-- 
-- Omit rows with invalid BBLs + BINs.  In general, these create 
-- havoc for our joins and checksums (and in theory, we will never
-- be able to match on these keys, anyway).  
--
-- We also omit columns which are also (in principle) dependent on our
-- de-facto primary keys, and which (in principle) can be retrieved by
-- joining on other tables.
--
create table push.hpd_building as
select id, bbl, bin, program, dob_class_id, legal_stories, legal_class_a, legal_class_b, lifecycle, status_id
from core.hpd_building
where public.is_valid_bbl(bbl) and public.is_valid_bin(bin);
create index on push.hpd_building(id);
create index on push.hpd_building(bbl);
create index on push.hpd_building(bin);

create table push.hpd_registration as
select id, bbl, building_id, bin, last_date, end_date 
from core.hpd_registration
where public.is_valid_bbl(bbl) and public.is_valid_bin(bin);
create index on push.hpd_registration(id);
create index on push.hpd_registration(bbl);
create index on push.hpd_registration(building_id);

create table push.hpd_contact as
select * from core.hpd_contact;
create index on push.hpd_contact(id);
create index on push.hpd_contact(contact_type);
create index on push.hpd_contact(registration_id);

create table push.hpd_legal as
select id, building_id, bbl, case_type, case_open_date, case_status, case_status_date, case_judgement 
from core.hpd_legal
where public.is_valid_bbl(bbl);
create index on push.hpd_legal(id);
create index on push.hpd_legal(bbl);
create index on push.hpd_legal(building_id);

create table push.hpd_complaint as
select * from core.hpd_complaint;
create index on push.hpd_complaint(id);
create index on push.hpd_complaint(building_id);
create index on push.hpd_complaint(bbl);

-- Not yet sure if we need all these date fields.
create table push.hpd_violation as
select 
  id, building_id, registration_id, bbl, apt, story, class,
  -- inspection_date, approved_date, original_certify_by_date, original_correct_by_date, 
  -- new_certify_by_date, new_correct_by_date, certified_date,  
  order_number, nov_id,  nov_description, nov_issue_date,
  status_id, status_text, status_date
from core.hpd_violation
where nov_id is not null; 
create index on push.hpd_violation(id);
create index on push.hpd_violation(building_id);
create index on push.hpd_violation(registration_id);
create index on push.hpd_violation(bbl);

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

create table push.hpd_contact_rank ( 
    id integer,
    contact_type text
);
insert into push.hpd_contact_rank (id,contact_type) values 
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
create index on push.hpd_contact_rank(contact_type);

-- Provies a relation mostly useful for telling us whether a given taxlot
-- is under HPD jurisdiction.  As a side benefit, we get the building count.
create table push.hpd_building_count as
select bbl,count(*) as building_count from push.hpd_building group by bbl;
create index on push.hpd_building_count(bbl);

commit;

