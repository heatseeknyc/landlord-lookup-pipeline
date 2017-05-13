
begin;

create table flat.nychpd_registration (
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

create table flat.nychpd_contact (
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


-- BuildingID|BoroID|Boro|HouseNumber|LowHouseNumber|HighHouseNumber|StreetName|Zip|Block|Lot|BIN|CommunityBoard|CensusTract|ManagementProgram|DoBBuildingClassID|DoBBuildingClass|LegalStories|LegalClassA|LegalClassB|RegistrationID|LifeCycle|RecordStatusID|RecordStatus
-- 1|1|MANHATTAN|403|401|403|EAST 6 STREET|10016|434|1|1005769|3|3200|PVT|1|OLD  LAW TENEMENT|5|7|0|110291|Building|1|Active
-- 2|1|MANHATTAN|1005|1005|1021|1 AVENUE|10022|1348|23|1039972|6|10800|PVT|24|NOT AVAILABLE|20|0|0|0|Building|1|Active

create table flat.nychpd_building (
    BuildingID integer not null,
    BoroID smallint not null,
    Boro text,
    HouseNumber text,
    LowHouseNumber text,
    HighHouseNumber text,
    StreetName text,
    Zip integer,
    Block integer not null,
    Lot smallint not null,
    BIN integer,
    CommunityBoard smallint,
    CensusTract integer,
    ManagementProgram text,
    DoBBuildingClassID smallint,
    DoBBuildingClass text,
    LegalStories integer,
    LegalClassA integer, 
    LegalClassB integer,
    RegistrationID integer,
    LifeCycle text,
    RecordStatusID smallint,
    RecordStatus text 
);


-- LitigationID|BuildingID|BoroID|Boro|HouseNumber|StreetName|Zip|Block|Lot|CaseType|CaseOpenDate|CaseStatus|CaseJudgement
-- 97729|33622|1|MANHATTAN|352|WEST 48 STREET|10036|1038|58|Tenant Action|4/14/2009|CLOSED|NO
-- 97731|37828|1|MANHATTAN|108|WEST 111 STREET|10026|1820|41|Tenant Action|4/14/2009|CLOSED|NO

create table flat.nychpd_legal (
    LitigationID integer primary key,
    BuildingID integer not null,
    BoroID smallint not null,
    Boro text not null,
    HouseNumber text,
    StreetName text,
    Zip integer null,
    Block integer not null,
    Lot smallint not null,
    CaseType text,
    CaseOpenDate date,
    CaseStatus text,
    CaseJudgement text
);

commit;

