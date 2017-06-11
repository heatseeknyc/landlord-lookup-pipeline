
begin;

create table push.misc_liensale as
select * from core.misc_liensale;

create table push.misc_nycha as
select * from core.misc_nycha;

commit;

