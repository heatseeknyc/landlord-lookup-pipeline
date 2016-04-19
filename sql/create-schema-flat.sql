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
}

commit;

