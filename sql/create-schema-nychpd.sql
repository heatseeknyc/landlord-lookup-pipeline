
begin;

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

