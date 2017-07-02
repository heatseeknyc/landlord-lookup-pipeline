
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

drop materialized view push.dcp_pad_bbl_count if exists cascade;
create materialized view push.dcp_pad_bbl_count as
select distinct(x.bbl) from (
  select distinct(bbl) as bbl from push.dcp_pad_bbl union 
  select distinct(lo_bbl) from push.dcp_pad_bbl union 
  select distinct(hi_bbl) from push.dcp_pad_bbl union 
  select distinct(bill_bbl) from push.dcp_pad_bbl 
) as x;

commit;

