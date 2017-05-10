
begin;

create table push.stable as
select * from core.stable;

create table push.stable_joined as
select * from flat.stable_joined;

commit;

