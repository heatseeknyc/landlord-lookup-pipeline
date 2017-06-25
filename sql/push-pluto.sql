begin;

create table push.pluto_taxlot as
select * from core.pluto_taxlot_remix;
create index on push.pluto_taxlot(bbl);

create view push.pluto_taxlot_tidy as
select bbl, address, owner_name, bldg_class, land_use, year_built, units_total, units_res, num_floors, num_bldgs, building_count
from push.pluto_taxlot;

create table push.pluto_building as
select * from core.pluto_building_ideal;
create index on push.pluto_building(bbl);
create index on push.pluto_building(bin);
create index on push.pluto_building(bbl,bin);

/*
create materialized view push.pluto_building_kosher as
select * from push.pluto_building where is_kosher_bin(bin);
create index on push.pluto_building_kosher(bbl);
create index on push.pluto_building_kosher(bin);
create index on push.pluto_building_kosher(bbl,bin);
*/



/*
create table push.pluto_building_canonical as
select * from core.pluto_building_canonical;
create index on push.pluto_building_canonical(bbl,bin);
*/

-- Yes, these next two statements just copy existing tables from the 'flat' schema. 
-- But the tables are small, and it's convenient to have everything together here 
-- in the 'push' schema.

create table push.pluto_refdata_bldgclass as
select * from flat.pluto_refdata_bldgclass;
create index on push.pluto_refdata_bldgclass(tag);

create table push.pluto_refdata_landuse as
select * from flat.pluto_refdata_landuse;
create index on push.pluto_refdata_landuse(tag);

--
-- Analytical views
--


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
select bbl, public.bbl2qblock(bbl) as qblock from flat.pluto_taxlot where public.is_condo_primary(bbl);
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

