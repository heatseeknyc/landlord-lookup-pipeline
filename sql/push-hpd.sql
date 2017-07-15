
begin;


-- Row counts for the June 2017 dataset.


--
-- Copy all rows, omitting columns which can be trivally slotted in from external 
-- datasets (like 'censustract' as well as street address, but retaining foreign keys.
-- 311065 rows
drop table if exists push.hpd_building cascade;
create table push.hpd_building as
select id, bbl, bin, program, dob_class_id, legal_stories, legal_class_a, legal_class_b, lifecycle, status_id, registration_id
from core.hpd_building;
create index on push.hpd_building(id);
create index on push.hpd_building(bbl);
create index on push.hpd_building(bin);

--
-- The first of several counting tables/views.  In this transaction at least,
-- all tables/views ending with "_count" are by BBL.  There's only one counting 
-- table that aggregates on (BBL,BIN), but it has a different suffix.
--

drop table if exists push.hpd_building_count cascade;
create table push.hpd_building_count as 
select bbl, count(*) as total from push.hpd_building group by bbl;
create index on push.hpd_building_count(bbl);

--
-- Next, we introduce a few restrictions.
--

-- First let's omit rows with invalid (or degenerate) BBLs and invalid BINs. 
-- 305199 rows
drop view if exists push.hpd_building_regular cascade;
create view push.hpd_building_regular as
select * from push.hpd_building
where is_valid_bbl(bbl) and not is_degenerate(bbl) and is_valid_bin(bin);


-- Then we restrict to what appear to be 'Active' records on currently existing buildings.
-- 294048 rows
drop view if exists push.hpd_building_active cascade;
create view push.hpd_building_active as 
select * from push.hpd_building_regular
where status_id = 1 and lifecycle = 'Building';


-- And an index of distinct, active buildings, a small percentage of which will have
-- multiple records per (BBL,BIN) pair.  We elect to take the more "recent" one (going by id)
-- as the "more active" one.
-- 292253 rows
drop view if exists push.hpd_building_distinct cascade;
create view push.hpd_building_distinct as 
select bbl, bin, count(*) as total, max(id) as last_id
from push.hpd_building_active group by bbl, bin;


-- Now we slot in all the other fields for that (BBL,BIN,id) tuple.
-- 292253 rows
drop table if exists push.hpd_building_current cascade; 
create table push.hpd_building_current as 
select 
   a.bbl, a.bin, b.id, b.program, 
   b.dob_class_id, b.legal_stories, b.legal_class_a, b. legal_class_b
from      push.hpd_building_distinct  as a
left join push.hpd_building_active as b on (a.bbl,a.bin,a.last_id) = (b.bbl,b.bin,b.id);
create index on push.hpd_building_current(bbl);
create index on push.hpd_building_current(bbl,bin);


-- 292253 rows
drop view if exists push.hpd_building_program cascade;
create view push.hpd_building_program as 
select 
    bbl, bin, id,
    case
        when program in ('NYCHA','7A','LOFT LAW','PVT') then program
        when program ~ '^M-L' then 'M-L'
        when program is not null then 'OTHER'
    end as program
from push.hpd_building_current;

-- 280520 rows
create view push.hpd_program_count as
select bbl, count(distinct program) as count_program, count(distinct bin) as count_bin
from push.hpd_building_program group by bbl;

/*
create view push.hpd_program_nice as
select bbl,count(distinct program) as program, count(distinct bin) as bin, min(program) as prog1, max(program) as prog2 
from push.hpd_building_program group by bbl;

create view push.hpd_taxlot_program_dirty as
select bbl,min(program) as program,count(distinct program) as count_program, count(distinct bin) as count_building
from push.hpd_building_program group by bbl;
*/

-- BBLs with first identifiable, non-PVT progam (that is, registered in some 
-- special program or another).  Thus far, any such BBL has only one non-special 
-- program (so the 'first' operator acts on only one value); thus, 'count_program' 
-- is thus far always equal to 1.  So if this presumed uniqueness ever changes  
-- in the future, we'll be able to tell by checking the `count_program` value.
--
-- In any case what we end up with is a relation of BBL to `program` for all 
-- taxlots that have are registered under a special program. 
--
-- 1736 rows
create view push.hpd_taxlot_special as
select bbl, first(program) as program, count(distinct program) as count_program, count(distinct bin) as count_building
from push.hpd_building_program where program is not null and program != 'PVT'
group by bbl;


-- 280520 rows, of which 1736 have special programs.
-- Note that the 'PVT' designation has been mapped to NULL.
drop table if exists push.hpd_taxlot_program cascade; 
create table push.hpd_taxlot_program as
select a.bbl, b.program as program, a.count_program, a.count_bin 
from      push.hpd_program_count as a 
left join push.hpd_taxlot_special as b on a.bbl = b.bbl;
create index on push.hpd_taxlot_program(bbl);






drop table if exists push.hpd_registration cascade;
create table push.hpd_registration as
select id, bbl, building_id, bin, last_date, end_date 
from core.hpd_registration
where public.is_regular_bbl(bbl) and public.is_valid_bin(bin);
create index on push.hpd_registration(id);
create index on push.hpd_registration(bbl);
create index on push.hpd_registration(building_id);

drop table if exists push.hpd_contact cascade;
create table push.hpd_contact as
select * from core.hpd_contact;
create index on push.hpd_contact(id);
create index on push.hpd_contact(contact_type);
create index on push.hpd_contact(registration_id);

drop view if exists push.hpd_contact_count cascade;
create view push.hpd_contact_count as
select a.bbl, count(*) as total
from      push.hpd_registration as a
left join push.hpd_contact      as b on a.id = b.registration_id
group by a.bbl;

drop table if exists push.hpd_legal cascade;
create table push.hpd_legal as
select id, building_id, bbl, case_type, case_open_date, case_status, case_status_date, case_judgement 
from core.hpd_legal
where public.is_regular_bbl(bbl);
create index on push.hpd_legal(id);
create index on push.hpd_legal(bbl);
create index on push.hpd_legal(building_id);
drop view if exists push.hpd_legal_count cascade;
create view push.hpd_legal_count as 
select bbl, count(*) as total from push.hpd_legal group by bbl;

drop table if exists push.hpd_complaint cascade;
create table push.hpd_complaint as
select * from core.hpd_complaint;
create index on push.hpd_complaint(id);
create index on push.hpd_complaint(building_id);
create index on push.hpd_complaint(bbl);
drop view if exists push.hpd_complaint_count cascade;
create view push.hpd_complaint_count as 
select bbl,count(*) as total from push.hpd_complaint group by bbl;

-- Not yet sure if we need all these date fields.
drop table if exists push.hpd_violation cascade;
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
drop view if exists push.hpd_violation_count cascade;
create view push.hpd_violation_count as 
select bbl, count(*) as total from push.hpd_violation group by bbl;

drop table if exists push.hpd_taxlot_summary cascade;
create table push.hpd_taxlot_summary as
select
  coalesce(a.bbl,b.bbl,c.bbl,d.bbl,e.bbl) as bbl,
  a.total as building,
  b.total as contact,
  c.total as complaint,
  d.total as violation,
  e.total as legal
from            push.hpd_building_count  as a
full outer join push.hpd_contact_count   as b on a.bbl = b.bbl
full outer join push.hpd_complaint_count as c on a.bbl = c.bbl
full outer join push.hpd_violation_count as d on a.bbl = d.bbl
full outer join push.hpd_legal_count     as e on a.bbl = e.bbl;
create index on push.hpd_taxlot_summary(bbl);

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

drop table if exists push.hpd_contact_rank cascade;
create table push.hpd_contact_rank ( 
    id integer,
    contact_type text
);
insert into push.hpd_contact_rank (id,contact_type) values 
    (1,'CorporateOwner'), (2,'IndividualOwner'), (3,'JointOwner'),
    (4,'HeadOfficer'), (5,'Officer'), (6,'Shareholder'),
    (7,'SiteManager'), (8,'Agent'), (9,'Lessee');
create index on push.hpd_contact_rank(contact_type);

commit;

