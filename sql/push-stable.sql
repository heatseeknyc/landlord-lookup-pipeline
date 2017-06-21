
begin;

create table push.stable_combined as
select * from core.stable_combined;
create index on push.stable_combined(bbl);

commit;

