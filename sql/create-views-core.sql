
begin;

--
-- MapPluto 16v2 - taxlots + buildings
--

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
from flat.pluto;

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


--
-- NYCHPD registrations + contacts
--

-- Renames columns + introduces BBL column. 
create view core.nychpd_registration as 
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
from flat.nychpd_registration;

create view core.nychpd_contact as 
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
from flat.nychpd_contact;

-- A restriction of the most recent taxbills rowset to just those tax lots 
-- having some kind of stability marking. 
create view core.taxbill_stable_2016Q4 as  
select bbl,unitcount,has_421a,has_j51
from flat.taxbills 
where year = 2016 and quarter = 4 and (has_421a or has_j51 or unitcount is not null);

-- A unified view of taxlots having stability markings across both data sources.
-- Current rowcount = 45261.
create view core.stable as
select 
  coalesce(a.bbl,b.bbl) as bbl, 
  a.has_421a or b.has_421a as has_421a,
  a.has_j51 or b.has_j51 as has_j51,
  b.unitcount, a.special,
  a.bbl is not null as in_dhcr,
  b.bbl is not null as in_taxbills
from flat.dhcr2015 as a
full outer join core.taxbill_stable_2016Q4 as b on a.bbl = b.bbl; 

commit;


