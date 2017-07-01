
begin;

drop view if exists core.pluto_taxlot cascade; 
create view core.pluto_taxlot as 
select
    BBL                   as bbl, 
    Address               as address, 
    ZipCode               as zip5, 
    AssessLand            as assess_land, 
    AssessTot             as assess_total, 
    BldgArea              as bldg_area, 
    BldgClass             as bldg_class,  
    CD                    as comm_dist,
    CondoNo               as condo_number,
    Council               as council,
    HistDist              as hist_dist, 
    LandUse               as land_use, 
    Landmark              as landmark, 
    NumBldgs              as num_bldgs, 
    NumFloors             as num_floors, 
    OwnerName             as owner_name, 
    OwnerType             as owner_type,  
    PLUTOMapID            as map_id, 
    UnitsRes              as units_res, 
    UnitsTotal            as units_total, 
    YearBuilt             as year_built,
    ZoneDist1             as zone_dist1, 
    ZoneDist2             as zone_dist2, 
    ZoneDist3             as zone_dist3, 
    ZoneDist4             as zone_dist4, 
    ZoneMap               as zone_map,
    SplitZone             as zone_split,
    lon_ctr               as lon_ctr, 
    lat_ctr               as lat_ctr, 
    radius                as radius, 
    parts                 as parts, 
    points                as points 
from flat.pluto_taxlot;

-- Omit a small number of rows with structurally invalid BBLs or BINs 
-- (3 in the former category, 1 in the latter, with 1 in the overlap).
drop view if exists core.pluto_building cascade; 
create view core.pluto_building as 
select * from flat.pluto_building
where is_valid_bbl(bbl) and is_valid_bin(bin);

-- An identity table restricted to regular BBLs (drops 143 outlier rows across 57 BBLs)
-- Our final 'push.pluto_building' will be 1-1 with this rowset.
drop materialized view if exists core.pluto_building_ideal cascade; 
create materialized view core.pluto_building_ideal as
select bbl, bin, doitt_id
from core.pluto_building where is_regular_bbl(bbl);
create index on core.pluto_building_ideal(bbl);
create index on core.pluto_building_ideal(bin);

drop materialized view if exists core.pluto_building_count cascade; 
create materialized view core.pluto_building_count as 
select 
    bbl, count(*) as total, count(distinct BIN) as bin
from core.pluto_building_ideal group by bbl;
create index on core.pluto_building_count(bbl);

-- Finds "orphaned" buildings in the buildings list but not in pluto.
/*
drop materialized view if exists core.pluto_building_orphan cascade; 
create materialized view core.pluto_building_orphan as
select a.bbl, a.bin, a.doitt_id
from      core.pluto_building_ideal as a
left join push.pluto_taxlot         as b on a.bbl = b.bbl where b.bbl is null;
create index on core.pluto_building_orphan(bbl);

drop materialized view if exists core.pluto_building_orphan_count cascade; 
create materialized view core.pluto_building_orphan_count as
select bbl, count(*) as total, count(distinct bin) as bin
    from core.pluto_building_orphan group by bbl;
create index on core.pluto_building_orphan_count(bbl);
*/

-- Gives us the "physical" building count per BBL, ie the number
-- of building shapefiles for each lot - as the NumBldgs column is 
-- known to be sometimes noisy.

-- An extension of our MapPluto set to include the above column.
-- If there's no BBL in the building set (which happens frequently,
-- for vacant lots) then we assign a building count of zero.
drop view if exists core.pluto_taxlot_remix cascade; 
create view core.pluto_taxlot_remix as
select a.*, coalesce(b.total,0) as building_count
from core.pluto_taxlot as a 
left join core.pluto_building_count as b on b.bbl = a.bbl;

commit;

