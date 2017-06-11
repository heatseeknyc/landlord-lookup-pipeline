
begin;

create table push.stable_confirmed as
select * from core.stable_confirmed;
create index on push.stable_confirmed(bbl);

commit;

