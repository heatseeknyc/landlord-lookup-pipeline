
begin;


/*

BOROUGH,Bin #,House #,Street Name,Job #,Job doc. #,Job Type,Self_Cert,Block,Lot,Community Board,Zip Code,Bldg Type,
Residential,Special District 1,Special District 2,Work Type,Permit Status,Filing Status,Permit Type,Permit Sequence #,Permit Subtype,
Oil Gas,Site Fill,Filing Date,Issuance Date,Expiration Date,Job Start Date,
Permittee's First Name,Permittee's Last Name,Permittee's Business Name,Permittee's Phone #,Permittee's License Type,Permittee's License #,
Act as Superintendent,Permittee's Other Title, HIC License, 
Site Safety Mgr's First Name, Site Safety Mgr's Last Name,Site Safety Mgr Business Name,
Superintendent First & Last Name,Superintendent Business Name,
Owner's Business Type,Non-Profit,Owner's Business Name,Owner's First Name,Owner's Last Name,Owner's House #,
Owner's House Street Name,Owner’s House City,Owner’s House State,Owner’s House Zip Code,Owner's Phone #,DOBRunDate
*/

-- Some columns have comments describing caveats observed in the most recent version (June 2017) 
-- of the raw CSV we've looked at.  Corrections for these are attempted in the corresponding view
-- in the 'core' schema.
create table flat.dob_permit (
    borough text not null,
    bin integer not null,
    house_number text,
    street_name text,
    job_id integer,
    job_doc_id integer,
    job_type char(2),
    self_cert char(1), -- appears as either 'Y' or NULL
    block integer,
    lot text, -- sometimes appears as a garbled mixture of digits and spaces 
    cb text, -- sometimes appears as a short string of spaces, or as NULL 
    zipcode text, -- usually integer or null, but sometimes 5 blank spaces
    bldg_type text, -- usually 1 or 2, sometimes spaces or null
    residential text, -- 'YES' or NULL
    sd1 text,
    sd2 text,
    work_type char(2), -- sometimes NULL or two spaces
    permit_status text, 
    filing_status char(7) not null, -- either 'INITIAL' or 'RENEWAL'
    permit_type text, 
    permit_sequence_id integer,
    permit_subtype char(2), -- sometimes NULL or two spaces
    oil_gas char(3), -- usually 'OIL' or 'GAS', but someimtes NULL or three spaces
    site_fill text, -- needs trimming
    filing_date date,
    issue_date date,
    expire_date date,
    start_date date,
    permittee_first_name text,
    permittee_last_name text,
    permittee_business_name text,
    permittee_phone_number text, -- not validated
    permittee_license_type text,
    permittee_license_id text, -- usually a 7-digit padded integer but sometimes shorter and/or needs trimming
    act_as_superintendent text, -- somtimes 'Y' but only in a few case; otherwise spaces or NULL 
    permittee_other_title text, 
    hic_license text, -- usually integer, sometimes needs trimming
    safety_manager_first_name text,
    safety_manager_last_name text,
    safety_manager_business_name text,
    superintendent_first_and_last_name text,
    superintendent_business_name text,
    owner_business_type text,
    nonprofit text, -- 'Y' or NULL,
    owner_business_name text,
    owner_first_name text,
    owner_last_name text,
    owner_house_number text,
    owner_house_street text,
    owner_house_city text,
    owner_house_state text, -- not validated
    owner_house_zipcode text, -- not validated
    owner_phone text, -- not validated
    dob_run_date date
);

commit;

