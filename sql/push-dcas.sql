
begin;

drop table if exists push.dcas_law48 cascade; 
create table push.dcas_law48 as select * from core.dcas_law48_tidy;
create index on push.dcas_law48(bbl);

drop table if exists push.dcas_ipis cascade; 
create table push.dcas_ipis as select * from core.dcas_ipis;
create index on push.dcas_ipis(bbl);

create view push.dcas_ipis_tidy as
select bbl, parcel_name, parcel_address, juris, agency, rpad, water, irreg, owntype, bldg_count renewal
from push.dcas_ipis;

commit;

