begin;

create table push.pluto_taxlot as
select * from core.pluto_taxlot_remix;
create index on push.pluto_taxlot(bbl);

create view push.pluto_taxlot_tidy as
select bbl, address, owner_name, bldg_class, land_use, year_built, units_total, units_res, num_floors, num_bldgs, building_count
from push.pluto_taxlot;

-- Records the "depth" of multiple matches on (bbl,bin) where the total is > 1 
/*
drop view if exists push.pluto_building_count_keytup cascade; 
create view push.pluto_building_count_keytup as
select bbl, bin, count(*) as total 
from core.pluto_building_ideal group by bbl, bin;

drop view if exists push.pluto_building_count_bin cascade; 
create view push.pluto_building_count_bin as
select bin, count(*) as total 
from core.pluto_building_ideal group by bin;
*/

drop table if exists push.pluto_building cascade; 
create table push.pluto_building as
select * from  core.pluto_building;;
create index on push.pluto_building(bbl);
create index on push.pluto_building(bin);
create index on push.pluto_building(bbl,bin);

drop materialized view if exists push.pluto_building_count cascade; 
create materialized view push.pluto_building_count as
select bbl, count(*) as total, count(distinct bin) as building
from push.pluto_building group by bbl; 

-- A counting table by (BBL,BIN) with the restriction that both columns 
-- are non-null.  Currently excludes the single tuple (NULL,0) in 16v2.
-- Yields 1081156 tuples.
create table push.pluto_keytup as
select bbl, bin, count(*) as total 
from push.pluto_building where bbl is not null and bin is not null
group by bbl, bin;
create index on push.pluto_keytup(bbl);
create index on push.pluto_keytup(bin);
create index on push.pluto_keytup(bbl,bin);


-- These next two statements just copy existing tables from the 'flat' schema. 
-- But the tables are small, and it's convenient to have everything together here 
-- in the 'push' schema.

drop table if exists push.pluto_refdata_bldgclass cascade; 
create table push.pluto_refdata_bldgclass as
select * from flat.pluto_refdata_bldgclass;
create index on push.pluto_refdata_bldgclass(tag);

drop table if exists push.pluto_refdata_landuse cascade; 
create table push.pluto_refdata_landuse as
select * from flat.pluto_refdata_landuse;
create index on push.pluto_refdata_landuse(tag);

--
-- Analytical views
--


-- "Orphaned" buildings/lots with no BBL in Pluto
drop materialized view if exists push.pluto_building_orphan cascade; 
create materialized view push.pluto_building_orphan as
select a.bbl, a.bin, a.doitt_id
from      push.pluto_building as a
left join push.pluto_taxlot         as b on a.bbl = b.bbl where b.bbl is null;
create index on push.pluto_building_orphan(bbl);

drop materialized view if exists push.pluto_building_orphan_count cascade; 
create materialized view push.pluto_building_orphan_count as
select bbl, count(*) as total, count(distinct bin) as bin 
from push.pluto_building_orphan group by bbl;
create index on push.pluto_building_orphan_count(bbl);




-- A pre-baked table of primary condo lots, with qualified block numbes slotted in.
-- Yields 7440 rows in 16v2.
create table push.pluto_condo as
select bbl, public.bbl2qblock(bbl) as qblock from flat.pluto_taxlot where public.is_condo_bbl(bbl);
create index on push.pluto_condo(bbl);
create index on push.pluto_condo(qblock);

create table push.pluto_coop as
select bbl from push.pluto_taxlot where public.is_coop_bldg_class(bldg_class);
create index on push.pluto_coop(bbl);

create table push.pluto_condo_qblock as
select qblock,count(*) as total from push.pluto_condo group by qblock;
create index on push.pluto_condo_qblock(qblock);


create view push.pluto_qblock_count as
select 
   public.bbl2qblock(bbl) as qblock, 
   count(*) as total
from push.pluto_taxlot 
group by public.bbl2qblock(bbl);

-- Ranges for "regular" no-condo lots, i.e below the 7501 range 
create view push.pluto_qblock_range as
select 
   public.bbl2qblock(bbl) as qblock, 
   min(public.bbl2lot(bbl)) as lot_min,
   max(public.bbl2lot(bbl)) as lot_max
from push.pluto_taxlot 
where public.bbl2lot(bbl) < 7500
group by public.bbl2qblock(bbl);

-- Condos per qblock
create view push.pluto_qblock_condo as
select qblock,count(*) as total from push.pluto_condo group by qblock;

-- So-caled overflow lots with numbers above the condo range.
create view push.pluto_qblock_overflow as
select 
   public.bbl2qblock(bbl) as qblock, 
   count(*) as total
from push.pluto_taxlot 
where public.bbl2lot(bbl) > 7599
group by public.bbl2qblock(bbl);

create table push.pluto_qblock_summary as
select 
   a.qblock, 
   b.lot_min, b.lot_max,
   coalesce(c.total,0) as condo, 
   coalesce(d.total,0) as overflow,
   a.total as total
from      push.pluto_qblock_count    as a
left join push.pluto_qblock_range    as b on a.qblock = b.qblock 
left join push.pluto_qblock_condo    as c on a.qblock = c.qblock 
left join push.pluto_qblock_overflow as d on a.qblock = d.qblock;
create index on push.pluto_qblock_summary(qblock);

commit;

