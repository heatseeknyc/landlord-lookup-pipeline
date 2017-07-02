
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

commit;

/*
drop table if exists push.dcp_wtf cascade;
create table push.dcp_wtf as
select 1 as k,bbl as bbl from push.dcp_pad_bbl union 
select 2,bill_bbl from push.dcp_pad_bbl;
*/


