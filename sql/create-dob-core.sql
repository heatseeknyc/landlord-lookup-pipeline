
begin;


-- Motivations for the various corrections can be understood by looking at the comments 
-- to each column in the 'flat' table this view pulls from (and hence, will date to the
-- dataset version that table definition references).
drop view if exists core.dob_permit cascade; 
create view core.dob_permit as  
select
    case 
        when (lot ~ '^\d+$' and length(lot) <= 5) then public.make_bbl(public.boroname2boroid(borough), block, lot::smallint) 
        else NULL
    end as bbl,
    bin,
    house_number,
    street_name,
    job_id,
    job_doc_id,
    job_type,
    case when self_cert = 'Y' then true else false end as self_cert,
    case when (cb ~ '^\d+$' and length(cb) < 5) then cb::smallint else null end as cb,
    case when (zipcode ~ '^\d+$' and length(zipcode) <= 5) then zipcode::integer else null end as zip5,
    case when (bldg_type ~ '^\d+$' and length(bldg_type) = 1) then bldg_type::smallint else null end as bldg_type,
    case when residential = 'YES' then true else false end as residential,
    sd1, sd2,
    case when work_type ~ '^\S+$' then work_type else null end as work_type,
    permit_status,
    filing_status,
    permit_type,
    permit_sequence_id,
    case when (permit_subtype ~ '^\S+$' and length(permit_subtype) = 2) then permit_subtype else null end as permit_subtype,
    case when (oil_gas ~ '^\S+$' and length(oil_gas) = 3) then oil_gas else null end as oil_gas,
    trim(site_fill) as site_fill,
    filing_date,
    issue_date,
    expire_date,
    start_date,
    permittee_first_name,
    permittee_last_name,
    permittee_business_name,
    permittee_phone_number,
    permittee_license_type,
    case when permittee_license_id ~ '^\d+$' then permittee_license_id::integer else null end as permittee_license_id,
    case when act_as_superintendent = 'Y' then true else false end as act_as_superintendent,
    case when hic_license ~ '^\d+$' then hic_license::integer else null end as hic_license,
    permittee_other_title, 
    safety_manager_last_name,
    safety_manager_business_name,
    superintendent_first_and_last_name,
    superintendent_business_name,
    owner_business_type,
    case when nonprofit = 'Y' then true else false end as nonprofit,
    owner_business_name,
    owner_first_name,
    owner_last_name,
    owner_house_number,
    owner_house_street,
    owner_house_city,
    owner_house_state, 
    owner_house_zipcode, 
    owner_phone, 
    dob_run_date 
from flat.dob_permit; 

commit;

