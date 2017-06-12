
begin;

create table push.dob_permit as
select * from core.dob_permit where 
    public.is_valid_bbl(bbl) and public.is_valid_bin(bin);
create index on push.dob_permit(bbl);
create index on push.dob_permit(bin);
create index on push.dob_permit(bbl,bin);

create table push.dob_violation as
select * from core.dob_violation where 
    public.is_valid_bbl(bbl) and public.is_valid_bin(bin);
create index on push.dob_violation(bbl);
create index on push.dob_violation(bin);
create index on push.dob_violation(bbl,bin);

create table push.dob_complaint as
select * from core.dob_complaint where public.is_valid_bin(bin);
create index on push.dob_complaint(bin);

commit;
