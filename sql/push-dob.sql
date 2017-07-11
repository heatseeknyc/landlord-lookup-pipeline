
begin;


--
-- Permits 
--

drop table if exists push.dob_permit cascade; 
create table push.dob_permit as
select * from core.dob_permit where 
    public.is_regular_bbl(bbl) and public.is_valid_bin(bin);
create index on push.dob_permit(bbl);
create index on push.dob_permit(bin);
create index on push.dob_permit(bbl,bin);
drop view if exists push.dob_permit_count cascade;
create view push.dob_permit_count as  
select bin,count(*) as total from push.dob_permit group by bin;

drop table if exists push.dob_permit_keytup cascade; 
create table push.dob_permit_keytup as
select bbl, bin, count(*) as total, count(distinct job_id) as job_id
from push.dob_permit group by bbl, bin;
create index on push.dob_permit_keytup(bbl,bin);
create index on push.dob_permit_keytup(bbl);

drop table if exists push.dob_permit_jobid cascade; 
create table push.dob_permit_jobid as
select 
    job_id, 
    count(*) as total, 
    count(distinct(bbl,bin)) as keytup, 
    count(distinct job_type) as job_type,
    count(distinct work_type) as work_type 
from push.dob_permit group by job_id; 
create index on push.dob_permit_jobid(job_id);


drop view if exists push.dob_permit_tidy cascade; 
create view push.dob_permit_tidy as
select 
    bbl, bin, 
    job_id, job_doc_id as doc_id, job_type,
    work_type, permit_status, filing_status, permit_type as type, permit_sequence_id as seq_id, permit_subtype as subtype,
    filing_date, start_date
from push.dob_permit;


--
-- Violations
--

drop table if exists push.dob_violation cascade; 
create table push.dob_violation as
select * from core.dob_violation where 
    public.is_regular_bbl(bbl) and public.is_valid_bin(bin);
create index on push.dob_violation(bbl);
create index on push.dob_violation(bin);
create index on push.dob_violation(bbl,bin);
drop view if exists push.dob_violation_count cascade;
create view push.dob_violation_count as  
select bin,count(*) as total from push.dob_violation group by bin;


--
-- Complaints 
--

drop table if exists push.dob_complaint cascade; 
create table push.dob_complaint as
select * from core.dob_complaint where public.is_valid_bin(bin);
create index on push.dob_complaint(bin);
drop view if exists push.dob_complaint_count cascade;
create view push.dob_complaint_count as  
select bin,count(*) as total from push.dob_complaint group by bin;


--
-- Summary 
--

drop table if exists push.dob_building_summary cascade;
create table push.dob_building_summary as
select
  coalesce(a.bin,b.bin,c.bin) as bin,
  a.total as permit, 
  b.total as violation,
  c.total as complaint
from            push.dob_permit_count    as a
full outer join push.dob_violation_count as b on a.bin = b.bin
full outer join push.dob_complaint_count as c on a.bin = c.bin;
create index on push.dob_building_summary(bin);

commit;
