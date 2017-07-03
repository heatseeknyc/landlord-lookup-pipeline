
begin;

drop table if exists push.dcp_pad_adr cascade; 
create table push.dcp_pad_adr as select * from core.dcp_pad_adr;
create index on push.dcp_pad_adr(bbl);
create index on push.dcp_pad_adr(bin);

drop table if exists push.dcp_pad_adr_count cascade; 
create table push.dcp_pad_adr_count as 
select bbl, count(*) as total, count(distinct bin) as bin from push.dcp_pad_adr group by bbl;
create index on push.dcp_pad_adr_count(bbl);

drop table if exists push.dcp_pad_bbl cascade; 
create table push.dcp_pad_bbl as select * from core.dcp_pad_bbl;
create index on push.dcp_pad_bbl(lo_bbl);
create index on push.dcp_pad_bbl(hi_bbl);
create index on push.dcp_pad_bbl(bbl);
create index on push.dcp_pad_bbl(bill_bbl);

drop table if exists push.dcp_pad_bbl_count cascade;
create table push.dcp_pad_bbl_count as
select distinct(x.bbl) from (
  select bbl as bbl from push.dcp_pad_bbl union 
  select bill_bbl from push.dcp_pad_bbl where bill_bbl is not null 
) as x;

-- A unified view of all (primary) BBLs between BBL+ADR tables
drop table if exists push.dcp_pad_outer cascade;
create table push.dcp_pad_outer as
select 
    coalesce(a.bbl,b.bbl) as bbl, 
    a.bbl as in_bbl, 
    b.bbl as in_pad
from            push.dcp_pad_bbl_count as a
full outer join push.dcp_pad_adr_count as b on a.bbl = b.bbl;

commit;

