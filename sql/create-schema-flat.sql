--
-- The 'flat' schema contains tables which align (nearly) verbatim 
-- with the raw CSV files provided obtained from HPD sources: 
-- 
--   RegistrationYYYYMMDD.txt, contacts-dedup.txt, bbl_lat_lng.txt
--  

begin;

drop schema if exists flat cascade;
create schema flat; 

create table flat.registrations (
    registrationid integer,
    buildingid integer,
    boroid smallint,
    boro text,
    housenumber text,
    lowhousenumber text,
    highhousenumber text,
    streetname text,
    streetcode text,
    zip text,
    block smallint,
    lot smallint, 
    bin integer,
    communityboard smallint,
    lastregistrationdate date,
    registrationenddate date
);

-- Note that  the 'Type' column in the contacts file, has been 
-- renamed to 'ContactType' to avoid collision on the reserved 
-- SQL word. 
create table flat.contacts (
    registrationcontactid integer,
    registrationid integer,
    contacttype text,
    contactdescription text,
    corporationname text,
    title text,
    firstname text,
    middleinitial text,
    lastname text,
    businesshousenumber text,
    businessstreetname text,
    businessapartment text,
    businesscity text,
    businessstate text,
    businesszip text
);

create table flat.taxbills (
    bbl bigint,
    active_date date,
    owner_name text,
    mailing_address text
);

create table flat.dhcr_tuples (
    bbl bigint,
    bin integer 
);

-- MAPPluto version 16v2
create table flat.pluto (
    BBL bigint,
    Address text,
    AssessLand float, 
    AssessTot float, 
    BldgArea integer,
    BldgClass text, 
    CD integer, 
    CondoNo integer,
    HistDist text, 
    LandUse text, 
    Landmark text, 
    NumBldgs integer,
    NumFloors float, 
    OwnerName text, 
    OwnerType text, 
    PLUTOMapID integer,
    UnitsRes integer, 
    UnitsTotal integer, 
    YearBuilt integer, 
    ZoneDist1 text, 
    ZoneDist2 text, 
    ZoneDist3 text, 
    ZoneDist4 text, 
    ZoneMap text 
);

create table flat.shape_building (
    bbl bigint,
    bin integer,
    doitt_id integer,
    lat_ctr float,
    lon_ctr float,
    radius float,
    parts text,
    points text
);

commit;
