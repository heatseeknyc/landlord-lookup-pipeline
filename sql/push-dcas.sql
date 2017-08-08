
begin;

drop table if exists push.dcas_law48 cascade; 
create table push.dcas_law48 as select * from core.dcas_law48_tidy;
create index on push.dcas_law48(bbl);

drop table if exists push.dcas_ipis cascade; 
create table push.dcas_ipis as select * from core.dcas_ipis;
create index on push.dcas_ipis(bbl);

create view push.dcas_ipis_tidy as
select bbl, name, address, juris, agency, rpad, water, irreg, owntype, bldg_count renewal
from push.dcas_ipis;

drop table if exists push.dcas_ipis_count cascade;
create table push.dcas_ipis_count as
select
    bbl,
    count(distinct name) as name,
    count(distinct address) as address,
    count(distinct juris) as juris,
    count(distinct agency) as agency,
    count(*) as total,
    first(juris) as firstjuris,
    first(name) firstname,
    first(address) firstaddr
from push.dcas_ipis group by bbl;
create index on push.dcas_ipis_count(bbl);

commit;

