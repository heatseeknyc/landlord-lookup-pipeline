
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

-- An identity table restricted to kosher BBLs (drops 143 outlier rows across 57 BBLs)
-- Our final 'push.pluto_building' will be 1-1 with this rowset.
drop materialized view if exists core.pluto_building_ideal cascade; 
create materialized view core.pluto_building_ideal as
select bbl, bin, doitt_id
from core.pluto_building where is_kosher_bbl(bbl);
create index on core.pluto_building_ideal(bbl);
create index on core.pluto_building_ideal(bin);

drop materialized view if exists core.pluto_building_count cascade; 
create materialized view core.pluto_building_count as 
select 
    bbl, count(*) as total, count(distinct BIN) as bin
from core.pluto_building_ideal group by bbl;


drop view if exists core.pluto_building_tidy cascade; 
create view core.pluto_building_tidy as
select 
    bbl, bin, doitt_id, 
    lat_ctr::float(1), lon_ctr::float(1), radius::float(1), 
    parts, substr(points,0,40) as points 
from core.pluto_building;

create materialized view core.pluto_building_orphan as
select a.*
from      core.pluto_building_tidy as a
left join push.pluto_taxlot        as b on a.bbl = b.bbl where b.bbl is null;

create view core.pluto_building_orphan_count as
select bbl, count(*) from core.pluto_building_orphan group by bbl;

-- Disambiguates those rare case (numbering about 348 rows) of (bbl,bin)
-- pairs matching more than one building record -- thus allowing us to use
-- the (bbl,bin) as a primary key.  Of course this dismbiguation is arbitary,
-- in that we just pick the BIN which matches the first DoITT ID, but 
-- that's OK for now.
drop view if exists core.pluto_building_canonical cascade; 
create view core.pluto_building_canonical as
select bbl, bin, min(doitt_id) as doitt_id
from core.pluto_building
group by bbl,bin;

-- Gives us the "physical" building count per BBL, ie the number
-- of building shapefiles for each lot - as the NumBldgs column is 
-- known to be sometimes noisy.

-- An extension of our MapPluto set to include the above column.
-- If there's no BBL in the building set (which happens frequently,
-- for vacant lots) then we assign a building count of zero.
drop view if exists core.pluto_taxlot_remix cascade; 
create view core.pluto_taxlot_remix as
select a.*,coalesce(b.bldg_count,0) as bldg_count
from core.pluto_taxlot as a 
left join core.pluto_building_count as b on b.bbl = a.bbl;

commit;

