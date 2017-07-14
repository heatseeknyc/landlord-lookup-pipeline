
begin;

drop table if exists push.dcas_law48 cascade; 
create table push.dcas_law48 as select * from core.dcas_law48_tidy;
create index on push.dcas_law48(bbl);

drop table if exists push.dcas_ipis cascade; 
create table push.dcas_ipis as select * from core.dcas_ipis;
create index on push.dcas_ipis(bbl);

commit;

