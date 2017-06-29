
begin;

drop table if exists push.pad_adr cascade; 
create table push.pad_adr as select * from core.pad_adr;
create index on push.pad_adr(bbl);
create index on push.pad_adr(bin);

drop table if exists push.pad_adr_count cascade; 
create table push.pad_adr_count as 
select bbl, count(*) as total, count(distinct bin) as bin from push.pad_adr group by bbl;
create index on push.pad_adr_count(bbl);

drop table if exists push.pad_bbl cascade; 
create table push.pad_bbl as select * from core.pad_bbl;
create index on push.pad_bbl(lo_bbl);
create index on push.pad_bbl(hi_bbl);
create index on push.pad_bbl(bbl);
create index on push.pad_bbl(bill_bbl);

commit;
