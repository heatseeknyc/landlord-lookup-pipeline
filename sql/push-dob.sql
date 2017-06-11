
begin;

create table push.dob_permit as
select * from core.dob_permit
where bbl is not NULL;
create index on push.dob_permit(bbl);
create index on push.dob_permit(bin);
create index on push.dob_permit(bbl,bin);

commit;
