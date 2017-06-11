
begin;

create table push.stable_confirmed as
select * from core.stable_confirmed;

commit;

