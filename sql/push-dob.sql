
begin;

create table push.dob_permit as
select * from core.dob_permit where 
    public.is_valid_bbl(bbl) and public.is_valid_bin(bin);
create index on push.dob_permit(bbl);
create index on push.dob_permit(bin);
create index on push.dob_permit(bbl,bin);
drop view if exists push.dob_permit_count cascade;
create view push.dob_permit_count as  
select bin,count(*) as total from push.dob_permit group by bin;

create table push.dob_violation as
select * from core.dob_violation where 
    public.is_valid_bbl(bbl) and public.is_valid_bin(bin);
create index on push.dob_violation(bbl);
create index on push.dob_violation(bin);
create index on push.dob_violation(bbl,bin);
drop view if exists push.dob_violation_count cascade;
create view push.dob_violation_count as  
select bin,count(*) as total from push.dob_violation group by bin;

create table push.dob_complaint as
select * from core.dob_complaint where public.is_valid_bin(bin);
create index on push.dob_complaint(bin);
drop view if exists push.dob_complaint_count cascade;
create view push.dob_complaint_count as  
select bin,count(*) as total from push.dob_complaint group by bin;

commit;
