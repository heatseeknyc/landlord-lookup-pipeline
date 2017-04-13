
begin;

--
-- Renames columns + introduces BBL column. 
--
create view core.registrations as 
select 
    registrationid       as id, 
    public.make_bbl(boroid,block,lot) as bbl,
    buildingid           as building_id,
    boroid               as boro_id,
    housenumber          as house_number,
    lowhousenumber       as house_number_low,
    highhousenumber      as house_number_high,
    streetname           as street_name, 
    streetcode           as street_code, 
    zip,
    block,             
    lot,
    bin,
    communityboard       as cb_id,
    lastregistrationdate as last_date,
    registrationenddate  as end_date
from flat.registrations;

create view core.contacts as 
select
    registrationcontactid as id, 
    registrationid        as registration_id,
    contacttype           as contact_type,
    contactdescription    as contact_description,
    title                 as contact_title,
    firstname             as contact_first_name, 
    middleinitial         as contact_middle_initial, 
    lastname              as contact_last_name,
    corporationname       as corporation_name, 
    businesshousenumber   as business_house_number, 
    businessstreetname    as business_street_name, 
    businessapartment     as business_apartment,
    businesscity          as business_city, 
    businessstate         as business_state,
    businesszip           as business_zip
from flat.contacts;

create view core.pluto as 
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
from flat.pluto;

-- Omit records with corrupted BBL/BIN pairs (currently 3 rows):
create view core.buildings as 
select * from flat.buildings
where
  bbl is not null and bbl >= 1000000000 and bbl < 6000000000 and
  bin is not null and bin >= 1000000;

-- Gives us the "physical" building count per BBL, ie the number
-- of building shapefiles for each lot.
create view core.building_counts as 
select bbl,count(*) as bldg_count from core.buildings group by bbl;

-- Because it's extremely convenient to have the "physical" building count  
-- as an extended attribute of pluto.
create view core.plutox as
select a.*,coalesce(b.bldg_count,0)
from core.pluto as a 
left join core.building_counts as b on b.bbl = a.bbl;

-- Omit corrupted BBL/BIN pairs, and add an "active" column
create view core.dhcr as 
select bbl, bin, 1 as active from flat.dhcr_pairs
where 
  bbl is not null and bbl >= 1000000000 and bbl < 6000000000 and
  bin is not null and bin >= 1000000 and bin not in (1000000,2000000,3000000,4000000,5000000);

commit;


