--
-- In which we analyze and reconcile the BBL+ADR tables in the PAD database,
-- culminating in very special table, "dcp_pad_outer", an outer join of the two. 
-- Note that we're forced to suffer from the poorly name for the BBL table, 
-- leading to constant confusion between the table name and the column name.
--
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

-- A counting table for (primary) BBLs in the BBL table. 
drop table if exists push.dcp_pad_bbl_count cascade;
create table push.dcp_pad_bbl_count as
select distinct(x.bbl) from (
  select bbl as bbl from push.dcp_pad_bbl union 
  select bill_bbl from push.dcp_pad_bbl where bill_bbl is not null 
) as x;
create index on push.dcp_pad_bbl_count(bbl);

-- A unified view of all (primary) BBLs between BBL+ADR tables.
-- That is, we only want "phyiscal" and "bank" BBLs, but not the (implied)
-- condo unit BBLs given by the lo/hi ranges.
-- 878205 rows for version 17b.
drop table if exists push.dcp_pad_outer cascade;
create table push.dcp_pad_outer as
select 
    coalesce(a.bbl,b.bbl) as bbl, 
    a.bbl is not null as in_bbl, 
    b.bbl is not null as in_adr
from            push.dcp_pad_bbl_count as a
full outer join push.dcp_pad_adr_count as b on a.bbl = b.bbl;
create index on push.dcp_pad_outer(bbl);

-- A status table that tells us if the BBL represents a simple coop
-- (and not a possibly erroneous condo/coop-hybrid), from the DCP's perspective.
-- 7226 rows.
drop table if exists push.dcp_coop cascade;
create table push.dcp_coop as
select distinct(bbl) from push.dcp_pad_bbl where coopnum > 0 and not is_condo_bbl(bill_bbl);
create index on push.dcp_coop(bbl);

-- A counting tabe on (BBL,BIN), where both columns are non-null  As of 17b, 
-- both colums are non-null, so no tuples are excluded by this restriction. 
-- But we including the restriction anyway to avoid any potential confusion
-- that may arise in future PAD releases.
-- Yields 1157327 tuples.
drop table if exists push.dcp_pad_keytup cascade;
create table push.dcp_pad_keytup as
select bbl, bin, count(*) as total 
from push.dcp_pad_adr where bbl is not null and bin is not null
group by bbl, bin;
create index on push.dcp_pad_keytup(bbl);
create index on push.dcp_pad_keytup(bin);
create index on push.dcp_pad_keytup(bbl,bin);

drop table if exists push.dcp_zoning cascade;
create table push.dcp_zoning as select * from core.dcp_zoning;
create index on push.dcp_zoning(bbl);
create index on push.dcp_zoning(zd1);
create index on push.dcp_zoning(mapnum);

commit;

