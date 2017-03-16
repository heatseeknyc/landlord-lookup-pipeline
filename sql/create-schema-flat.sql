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

create table flat.dhcr_pairs (
    bbl bigint not null,
    bin integer not null 
);

-- MAPPluto version 16v2
-- Note that BBL, and the 5 lower-case fields at the bottom are generated 
-- by our ETL process; all other fields are as-is (and appear in the order
-- as they appear in the data dictionary).
create table flat.pluto (
    BBL bigint PRIMARY KEY,
    ZipCode integer,
    Address text,
    AssessLand float, 
    AssessTot float, 
    BldgArea integer,
    BldgClass char(2), 
    CD integer, 
    CondoNo integer,
    HistDist text, 
    LandUse char(2), 
    Landmark text, 
    NumBldgs integer,
    NumFloors float, 
    OwnerType char(1), 
    OwnerName text, 
    PLUTOMapID integer,
    UnitsRes integer, 
    UnitsTotal integer, 
    YearBuilt integer, 
    ZoneDist1 text, 
    ZoneDist2 text, 
    ZoneDist3 text, 
    ZoneDist4 text, 
    ZoneMap text,
    SplitZone char(1),
    lat_ctr float,
    lon_ctr float,
    radius float,
    parts text,
    points text
);
-- possible TODOs in this table: 
--  - LandUse could be cast to smallint
--  - SplitZone is ok as-is in this table, but could be normalized to boolean in push.pluto 

create table flat.buildings (
    bbl bigint,
    bin integer,
    doitt_id integer primary key,
    lat_ctr float,
    lon_ctr float,
    radius float,
    parts text,
    points text
);

commit;
