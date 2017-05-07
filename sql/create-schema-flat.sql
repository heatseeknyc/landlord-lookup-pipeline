--
-- The 'flat' schema contains tables which align (nearly) verbatim 
-- with the raw CSV files provided obtained from HPD sources: 
-- 
--   RegistrationYYYYMMDD.txt, contacts-dedup.txt, bbl_lat_lng.txt
--  

begin;

drop schema if exists flat cascade;
create schema flat; 

-- MAPPluto version 16v2
-- Note that BBL, and the 5 lower-case fields at the bottom are generated 
-- by our ETL process; all other fields are as-is (and appear in the order
-- as they appear in the data dictionary).
create table flat.pluto_taxlot (
    BBL bigint PRIMARY KEY,
    ZipCode integer,
    Address text,
    AssessLand float, 
    AssessTot float, 
    BldgArea integer not null,
    BldgClass char(2), 
    CD smallint not null, 
    CondoNo smallint not null,
    Council smallint not null,
    HistDist text, 
    LandUse char(2), 
    Landmark text, 
    NumBldgs integer not null,
    NumFloors float not null, 
    OwnerType char(1), 
    OwnerName text, 
    PLUTOMapID smallint not null,
    UnitsRes integer not null, 
    UnitsTotal integer not null, 
    YearBuilt smallint not null, 
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

create table flat.pluto_building (
    bbl bigint,
    bin integer not null,
    doitt_id integer primary key,
    lat_ctr float,
    lon_ctr float,
    radius float,
    parts text,
    points text
);

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
    block integer, 
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
    bbl bigint CHECK (bbl >= 1000000000 and bbl < 6000000000),
    year smallint CHECK (year > 0),
    quarter smallint CHECK (quarter >= 1 and quarter <= 4),
    htype smallint CHECK (htype >= 1 and htype <= 2),
    taxclass varchar(2) null,
    unitcount smallint null,
    estimated bigint null,
    amount float(2),
    has_421a boolean,
    has_j51 boolean,
    UNIQUE (bbl, year, quarter)
);

create table flat.dhcr2015 ( 
    bbl bigint primary key,
    count integer not null,
    dwell char(1),
    has_421a boolean not null,
    has_j51 boolean not null,
    special text
);

create table flat.liensales (
    bbl bigint CHECK (bbl >= 1000000000 and bbl < 6000000000),
    year integer CHECK (year > 0),
    taxclass integer,
    waterdebt boolean,
    UNIQUE (bbl, year)
);

-- deprecated
create table flat.taxbills_deprecated (
    bbl bigint,
    active_date date,
    owner_name text,
    mailing_address text
);

-- deprecated
create table flat.dhcr_lots ( 
    bbl bigint primary key,
    count integer not null,
    tags text
);

-- deprecated
create table flat.dhcr_pairs (
    bbl bigint not null,
    bin integer not null 
);


commit;

