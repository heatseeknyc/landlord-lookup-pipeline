
begin;

drop table if exists push.dcas_law48 cascade; 
create table push.dcas_law48 as select * from core.dcas_law48_tidy;
create index on push.dcas_law48(bbl);

commit;

