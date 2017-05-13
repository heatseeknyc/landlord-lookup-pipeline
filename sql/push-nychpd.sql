
begin;

create table push.nychpd_registration as
select *  from core.nychpd_registration;

create table push.nychpd_contact as
select * from core.nychpd_contact;

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

create table push.nychpd_contact_rank ( 
    id integer,
    contact_type text
);

insert into push.nychpd_contact_rank (id,contact_type) values 
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

commit;

