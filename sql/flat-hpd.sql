
begin;

create table flat.hpd_building (
    BuildingID integer not null,
    BoroID smallint not null,
    Boro text,
    HouseNumber text,
    LowHouseNumber text,
    HighHouseNumber text,
    StreetName text,
    Zip text, -- sometimes blank spaces
    Block integer not null,
    Lot smallint not null,
    BIN integer,
    CommunityBoard smallint,
    CensusTract text, -- sometimes has embedded period, eg "195.00" 
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

create table flat.hpd_registration (
    RegistrationID integer,
    BuildingID integer,
    BoroID smallint,
    Boro text,
    HouseNumber text,
    LowHouseNumber text,
    HighHouseNumber text,
    StreetName text,
    StreetCode text,
    Zip text,
    Block integer, 
    Lot smallint, 
    BIN integer,
    CommunityBoard smallint,
    LastRegistrationDate date,
    RegistrationEndDate date
);

create table flat.hpd_contact (
    RegistrationContactID integer,
    RegistrationID integer,
    ContactType text,
    ContactDescription text,
    CorporationName text,
    Title text,
    FirstName text,
    MiddleInitial text,
    LastName text,
    BusinessHouseNumber text,
    BusinessStreetName text,
    BusinessApartment text,
    BusinessCity text,
    BusinessState text,
    BusinessZip text
);

create table flat.hpd_legal (
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

create table flat.hpd_complaint (
    ComplaintID integer primary key,
    BuildingID integer not null,
    BoroughID smallint not null,
    Borough text not null,
    HouseNumber text,
    StreetName text,
    Zip integer,
    Block integer not null,
    Lot smallint not null,
    Apartment text,
    CommunityBoard smallint,
    ReceivedDate date not null,
    StatusID smallint not null,
    Status text not null,
    StatusDate date not null
);

create table flat.hpd_violation (
    ViolationID integer primary key,
    BuildingID integer not null,
    RegistrationID integer not null,
    BoroID smallint not null,
    Boro text not null,
    HouseNumber text,
    LowHouseNumber text,
    HighHouseNumber text,
    StreetName text,
    StreetCode text,
    Zip integer,
    Apartment text,
    Story text,
    Block integer not null,
    Lot smallint not null,
    Class char(1) not null,
    InspectionDate date,
    ApprovedDate date,
    OriginalCertifyByDate date,
    OriginalCorrectByDate date,
    NewCertifyByDate date,
    NewCorrectByDate date,
    CertifiedDate date,
    OrderNumber text,
    NOVID integer,
    NOVDescription text,
    NOVIssuedDate date,
    CurrentStatusID smallint not null,
    CurrentStatus text,
    CurrentStatusDate date
);

commit;

