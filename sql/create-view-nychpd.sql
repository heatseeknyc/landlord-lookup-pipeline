
begin;

drop view if exists core.nychpd_building cascade; 
create view core.nychpd_building as 
select 
    buildingid           as id,
    public.make_bbl(boroid,block,lot) as bbl,
    housenumber          as house_number,
    lowhousenumber       as house_number_low,
    highhousenumber      as house_number_high,
    streetname           as street_name, 
    zip                  as zip5,
    bin                  as bin, 
    communityboard       as cb_id,
    censustract          as census,
    managementprogram    as program,
    dobbuildingclassid   as dob_class_id,
    dobbuildingclass     as dob_class,
    legalstories         as legal_stories,
    legalclassa          as legal_class_a,
    legalclassb          as legal_class_b,
    registrationid       as registration_id,
    lifecycle            as lifecycle,
    recordstatusid       as status_id,
    recordstatus         as status
from flat.nychpd_building;

drop view if exists core.nychpd_registration cascade; 
create view core.nychpd_registration as 
select 
    registrationid       as id, 
    public.make_bbl(boroid,block,lot) as bbl,
    buildingid           as building_id,
    housenumber          as house_number,
    lowhousenumber       as house_number_low,
    highhousenumber      as house_number_high,
    streetname           as street_name, 
    streetcode           as street_code, 
    zip                  as zip5,
    bin                  as bin,
    communityboard       as cb_id,
    lastregistrationdate as last_date,
    registrationenddate  as end_date
from flat.nychpd_registration;

drop view if exists core.nychpd_contact cascade; 
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

drop view if exists core.nychpd_legal cascade; 
create view core.nychpd_legal as 
select
    litigationid                      as id,
    buildingid                        as building_id,
    public.make_bbl(boroid,block,lot) as bbl,
    housenumber                       as house_number,
    streetname                        as street_name,
    zip                               as zip5,
    casetype                          as case_type,
    caseopendate                      as case_open_date, 
    case 
        when casestatus = 'CLOSED' then 'Closed'
        when casestatus in ('PENDING','APPLICATION PENDING') then 'Pending'
        when casestatus ~ '^GRANTED.*' then 'Granted'
        when casestatus ~ '^DENIED.*' then 'Denied'
        when casestatus ~ '^WithDrawn/Abandoned*' then 'Withdrawn'
        when casestatus ~ '^Exempt.*' then 'Exempt'
        when casestatus ~ '^Rejected.*' then 'Rejected'
        when casestatus ~ '^Rescinded.*' then 'Rescinded'
    end as case_status,
    case
        when casestatus ~ '.*\s\d+/\d+/\d+' then 
            date(array_to_string(regexp_matches(casestatus,'^.*\s(\d+/\d+/\d+).*'),''))
        else null
    end as case_status_date,
    case 
      when casejudgement = 'YES' then True 
      when casejudgement = 'NO' then False 
    end as case_judgement
from flat.nychpd_legal;

drop view if exists core.nychpd_complaint cascade; 
create view core.nychpd_complaint as 
select
    ComplaintID                          as id,
    BuildingID                           as building_id, 
    public.make_bbl(BoroughID,Block,Lot) as bbl,
    Apartment                            as apt, 
    ReceivedDate                         as received_id, 
    StatusID                             as status_id, 
    StatusDate                           as status_date 
from flat.nychpd_complaint;

/*
create table flat.nychpd_violation (
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
*/

commit;

