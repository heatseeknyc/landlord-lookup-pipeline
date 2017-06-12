
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
-- in the 'core' schema.  Unless stated otherwise, the implied 'broken' or outlier cases for each 
-- column are very low in frequency.
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
    lot text, -- usually 0-padded, 5-digit string but sometimes appears as a garbled mixture of digits and spaces
    cb text, -- sometimes appears as a short string of spaces, or as NULL
    zipcode text, -- usually integer or null, but sometimes 5 blank spaces
    bldg_type text, -- usually 1 or 2, sometimes spaces or NULL
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
    hic_license text, -- usually 0-padded 7-digit integer, sometimes spaces or NULL
    safety_manager_first_name text,
    safety_manager_last_name text,
    safety_manager_business_name text,
    superintendent_first_and_last_name text,
    superintendent_business_name text,
    owner_business_type text,
    nonprofit text, -- 'Y' or NULL
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

-- ISN_DOB_BIS_VIOL,BORO,BIN,BLOCK,LOT,ISSUE_DATE,VIOLATION_TYPE_CODE,VIOLATION_NUMBER,HOUSE_NUMBER,STREET,DISPOSITION_DATE,DISPOSITION_COMMENTS,DEVICE_NUMBER,DESCRIPTION,ECB_NUMBER,NUMBER,VIOLATION_CATEGORY,VIOLATION_TYPE 
-- 493111,1,1014517,00790,00009,19970916,LL6291,171810,147R,WEST   14 STREET,,,00913773,,,V091697LL6291171810,V-DOB VIOLATION - ACTIVE,LL6291-LOCAL LAW 62/91 - BOILERS
create table flat.dob_violation (
    isn_dob_bis_viol integer,
    boro char(1), -- sometimes a single character "`" which apparently means not known
    bin integer,
    block text, -- usually 5 digits (padded), but somtimes has punctuation or other garbage
    lot text, -- usually 5 digitts (padded), but sometimes fewer, and/or has embedded spaces
    issue_date text, -- usually YYYYMMDD sometimes contains embedded spaces,
    violation_type_code text,
    violation_number text,
    house_number text,
    street text,
    disposition_date char(8), -- sometime invalid, e.g. '19940231'
    disposition_comments text,
    device_number text, 
    description text,
    ecb_number text,
    number text,
    violation_category text,
    violation_type text
);

-- Complaint Number,Status,Date Entered,House Number,ZIP Code,House Street,BIN,Community Board,Special District,Complaint Category,Unit,Disposition Date,Disposition Code,Inspection Date,DOBRunDate
-- 4483428,CLOSED,06/08/2011,10          ,,MUHLEBACH COURT                 ,4298330,414,   ,05,QNS.,04/25/2013,L3,04/25/2013,04/26/2013 12:00:00 AM
-- 1347475,CLOSED,04/23/2013,157         ,,BROOME STREET                   ,1004077,103,   ,23,SCFLD,04/25/2013,A8,04/25/2013,04/26/2013 12:00:00 AM
create table flat.dob_complaint (
    complaint_number integer,
    status text,
    entry_date date,
    house_number text,
    zipcode text,
    house_street text,
    bin integer,
    cb text, -- sometimes 3 blank spaces
    sd text,
    category text,
    unit text,
    disposition_date text, -- usually MM/DD/YYYY but sometimes not
    disposition_code text,
    inspection_date char(10), -- sometimes broken, e.g. '10/06/0000'
    dob_run_date timestamp 
);


commit;

