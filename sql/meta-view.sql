begin;

-- A view of DOB complaints, unified across DOB and Pluto.
-- Some important notes:
--
--    - DOB has a much smaller number of BINs than Pluto (some 320k v. 1.1M, as of June 2017).
--      this is because the DOB set only records buildings with permit/complaint activity.
--
--    - That said a significant number of rows (23499) appear in DOB but not in Pluto. 
--      These are most likely newer buildings that Pluto doesn't know about yet!
--
--    - Nonetheless (by definition) it will include every BBL in the Pluto building set.
--
drop view if exists meta.dob_building_summary cascade;
create view meta.dob_building_summary as 
select
    a.bbl, coalesce(a.bin,b.bin) as bin,
    b.permit, b.violation, b.complaint,
    a.bin is not null as in_pluto,
    b.bin is not null as in_dob
from            push.pluto_building       as a
full outer join push.dob_building_summary as b on a.bin = b.bin;

drop view if exists meta.dob_taxlot_summary cascade;
create view meta.dob_taxlot_summary as 
select 
    bbl,
    sum(permit) as permit,
    sum(violation) as violation,
    sum(complaint) as complaint
from meta.dob_building_summary where in_pluto group by bbl;

-- A magical view which (portends to) tell us whether a given property 
-- is residential or not (via the derived 'status' flag).  There's still
-- some room for improvement with this determination, but it's probably
-- good enough for now.
drop view if exists meta.residential cascade;
create view meta.residential as
select
  coalesce(a.bbl,b.bbl) as bbl,
  a.units_res       as units_res,
  a.condo_number    as condo_number,
  a.building_count      as pluto_building_count,
  b.building        as hpd_building_count,
  a.bbl is not null as in_pluto,
  b.bbl is not null as in_hpd,
  a.units_res > 0 or a.condo_number > 0 or b.bbl is not null
       as status 
from push.pluto_taxlot as a
full outer join push.hpd_taxlot_summary as b on b.bbl = a.bbl;

drop view if exists meta.stable_likely cascade;
create view meta.stable_likely as
select bbl from push.pluto_taxlot where units_res >= 6 and year_built <= 1974;

--
-- A comprehensive view on rent sabilization status by taxlot.  
--
-- Provides the crucial 'status' flag, which is defined as follows: 
-- 
--    'confirmed' if at least one of the properties  on the lot is on the DHCR list, 
--     the taxlot has non-zero unitcounts (in the taxbill scrapes) through 2015.
--
--    'disputed' if the lot has no buildings on the DHCR list, and its last year 
--     of appearance is before 2015.  (Implicating being it likely was stabilized
--     in the past, but may no longer have stabilized units).
--
--     'likely' if neither of the above criteria are met, but the property meets 
--     generic criteria for stabilization (pre-1974, 6 or more units),
--
-- A couple of notes as to the above:
--
--     - Due to the logic of how this table is constructed, every row will have
--       on of the above 3 values (i.e. there will be no rows with NULL status).
--
--     - So it shows up as NULL in a left join, that means the lot was most likely
--       never stabilized.
--
--     -- Some of the above flags have different definitions in other rowsets.
--        For example, presence in the 'stable_likely' view (which the select for
--        this view pulls from) simply means that the tax lot meets pre-1974 criteria; 
--        whereas in this view it means that it meets those criteria, -and- is not 
--        otherwise 'confirmed' or 'disputed'.
--
create view meta.stabilized as
select
  coalesce(a.bbl,b.bbl) as bbl,
  a.taxbill_lastyear,
  a.taxbill_unitcount,
  a.taxbill_abatements,
  a.dhcr_bldg_count,
  a.dhcr_421a,
  a.dhcr_j51,
  a.dhcr_special,
  case
    when a.dhcr_bldg_count > 0 or a.taxbill_lastyear = 2015 then 'confirmed'
    when a.taxbill_lastyear < 2015 then 'disputed'
    when b.bbl is not null then 'likely'
  end as status
from            push.stable_combined  as a
full outer join meta.stable_likely    as b on a.bbl = b.bbl; 

--
-- A crucial joining view that can be used to tell us everything we need
-- to know about either a building (given a BBL,BIN pair) -or- a taxlot
-- (if given just the BBL).  In the later case, you'll want to use a
-- "LIMIT 1" in the select, because of course (for multi-building lots)
-- all of the attributes will be redundant.
--
drop view if exists meta.property_summary cascade;
create view meta.property_summary as
select 
  a.bbl, b.bin, b.doitt_id, 
  a.land_use                 as pluto_land_use,
  a.bldg_class               as pluto_bldg_class,
  a.condo_number             as pluto_condo_number,
  a.units_total              as pluto_units_total,
  a.units_res                as pluto_units_res,
  a.building_count           as pluto_bldg_count,
  a.address                  as pluto_address,
  public.bbl2boroname(a.bbl) as pluto_borough,
  a.lon_ctr                  as pluto_lon_ctr,
  a.lat_ctr                  as pluto_lat_ctr,
  a.radius                   as pluto_radius,
  a.points                   as pluto_points,
  a.parts                    as pluto_parts,
  c.lon_ctr                  as building_lon_ctr,
  c.lat_ctr                  as building_lat_ctr,
  c.radius                   as building_radius,
  c.points                   as building_points,
  c.parts                    as building_parts,
  d.status                   as stable_status,
  coalesce(e.contact,0)      as hpd_contact_count,
  coalesce(e.complaint,0)    as hpd_complaint_count,
  coalesce(e.violation,0)    as hpd_violation_count,
  coalesce(e.legal,0)        as hpd_legal_count,
  coalesce(f.permit,0)       as dob_permit_count,
  coalesce(f.complaint,0)    as dob_complaint_count,
  coalesce(f.violation,0)    as dob_violation_count,
  g.status                   as residential_likely
from      push.pluto_taxlot           as a 
left join push.pluto_building_canonical as b on a.bbl = b.bbl
left join push.pluto_building         as c on b.bbl = c.bbl and b.doitt_id = c.doitt_id
left join meta.stabilized             as d on a.bbl = d.bbl
left join push.hpd_taxlot_summary     as e on a.bbl = e.bbl 
left join meta.dob_taxlot_summary     as f on a.bbl = f.bbl 
left join meta.residential            as g on a.bbl = g.bbl;

-- Everything you really need to know about a given taxlot. 
drop view if exists meta.taxlot cascade;
create view meta.taxlot as
select 
    a.*,
    b.land_use, b.units_total, b.units_res, b.building_count, b.year_built, 
    b.address, b.owner_name, b.lon_ctr, b.lat_ctr, b.radius, b.parts
from omni.taxlot_origin     as a
left join push.pluto_taxlot as b on a.bbl = b.bbl;







-- A simplified view of push.contacts with some column names, other columns 
-- catenated for brevity / tidier reporting (and minus contact_title), and the
-- ordering rank for contact_type slotted in.
drop view if exists meta.contact_simple cascade;
create view meta.contact_simple as 
select 
  a.id as contact_id, registration_id, a.contact_type, b.id as contact_rank, 
  contact_description as description, corporation_name as corpname, 
  public.make_contact_name(contact_first_name,contact_middle_initial,contact_last_name) as contact_name,
  public.make_contact_addr(
    business_house_number,business_street_name,business_apartment,business_city,business_state,business_zip
  ) as business_address 
from push.hpd_contact           as a
left join push.hpd_contact_rank as b on b.contact_type = a.contact_type;

--
-- And this view provides all contacts for a given (BBL,BIN) using shortened 
-- contact information fields defined above, and registration fields of potential
-- interest slotted in (some of which are useful for diagnostic purposes, even
-- though they don't appear in the UI). It also gets pushed to the "hard" scheme, 
-- into a table of the same name.
--
-- Note that because we're left-joining on registrations, we aren't guaranteed 
-- that all our contacts records will be retrieved; and indeed (as of Feb 2016)
-- around 1 % of all contact records are thusly "orphaned" -- due to the fact 
-- they were orphaned in the original data (i.e. had no registration IDs in 
-- the files as they came to us from the NYCHPD).
-- 
drop view if exists meta.contact_info cascade;
create view meta.contact_info as
select 
  a.id as registration_id, bin, bbl, building_id, last_date, end_date,
  b.contact_id, b.contact_type, b.contact_rank, b.description, 
  b.corpname, b.contact_name, b.business_address
from push.hpd_registration    as a
left join meta.contact_simple as b on b.registration_id = a.id;

commit;

