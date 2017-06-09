
begin;

create table push.dob_permit as
select * from core.dob_permit
where bbl is not NULL;

commit;
