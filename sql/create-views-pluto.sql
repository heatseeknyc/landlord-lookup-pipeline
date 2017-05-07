
begin;

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

-- Omit a small number of rows with clearly degenerate BBLs or BINs 
-- (exactly 3 fail these criteria in 16v2).  This sill still leave us 
-- with a significant number (6000+) of rows with "noisy" BBLs or BINs
-- (or both), but that's OK for now.
create view core.pluto_building as 
select * from flat.pluto_building
where 
  bbl is not null and 
  bbl >= 1000000000 and bbl < 6000000000 and
  bbl >= 1000000 and bin < 6000000;

-- Disambiguates those rare case (numbering about 348 rows) of (bbl,bin)
-- pairs matching more than one building record -- thus allowing us to use
-- the (bbl,bin) as a primary key.
create view core.pluto_building_primary as
select bbl, bin, min(doitt_id) as doitt_id
from core.pluto_building
group by bbl,bin;

-- Gives us the "physical" building count per BBL, ie the number
-- of building shapefiles for each lot - as the NumBldgs column is 
-- known to be sometimes noisy.
create view core.pluto_building_count as 
select bbl,count(*) as bldg_count from core.pluto_building group by bbl;

-- An extension of our MapPluto set to include the above column.
create view core.pluto_taxlot_remix as
select a.*,coalesce(b.bldg_count,0) as bldg_count
from core.pluto_taxlot as a 
left join core.pluto_building_count as b on b.bbl = a.bbl;

commit;

