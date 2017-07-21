
begin;

create table push.misc_liensale as
select * from core.misc_liensale;

create table push.misc_nycha as
select * from core.misc_nycha;

create table push.misc_dev_rel as select * from flat.misc_dev_rel;
create index on push.misc_dev_rel(bbl);
create index on push.misc_dev_rel(devid);

create table push.misc_dev_ent as select * from flat.misc_dev_ent;
create index on push.misc_dev_ent(id);

commit;

