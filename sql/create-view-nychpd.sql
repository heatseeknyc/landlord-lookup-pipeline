
begin;

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
    zip                  as zip5,
    bin                  as bin,
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

commit;

