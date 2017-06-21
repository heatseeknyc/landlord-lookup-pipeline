
begin;

drop table if exists push.stable_combined cascade; 
create table push.stable_combined as
select * from core.stable_combined;
create index on push.stable_combined(bbl);

commit;

