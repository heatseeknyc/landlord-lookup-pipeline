begin;

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

create table flat.pluto_refdata_bldgclass (
    tag char(2) not null primary key,
    label text
);

create table flat.pluto_refdata_landuse (
    tag char(2) not null primary key,
    label text
);

commit;

