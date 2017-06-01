
begin;

create table push.misc_stable as
select * from core.misc_stable;

create table push.misc_joined as
select * from flat.misc_joined;

create table push.misc_liensale as
select * from core.misc_liensale;

create table push.misc_nycha as
select * from core.misc_nycha;

commit;

