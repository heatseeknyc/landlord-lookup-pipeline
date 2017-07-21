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
  a.bldg_count      as pluto_bldg_count,
  b.building        as hpd_building_count,
  a.bbl is not null as in_pluto,
  b.bbl is not null as in_hpd,
  -- a.units_res > 0 or a.condo_number > 0 or b.bbl is not null
  a.units_res > 0 or b.bbl is not null
       as status 
from push.pluto_taxlot as a
full outer join push.hpd_taxlot_summary as b on b.bbl = a.bbl;


--
-- Everything you really need to know about a given taxlot. 
-- 
drop view if exists meta.taxlot cascade;
create view meta.taxlot as
select 
    a.bbl, 
    a.bbltype,
    a.in_pad_meta as in_pad,
    f.bbl is not null        as is_coop,
    is_condo_bbl(a.bbl)      as is_bank,
    coalesce(e.status,false) as is_resi,
    d.status             as stable_code,
    case when d.dhcr_bldg_count > 0 then 1 else null end 
                         as stable_dhcr_ok,
    d.taxbill_lastyear   as stable_taxbill_lastyear, 
    d.taxbill_unitcount  as stable_taxbill_unitcount, 
    b.land_use           as pluto_land_use, 
    b.bldg_class         as pluto_bldg_class,
    b.bldg_count         as pluto_bldg_count, 
    b.zone_dist1         as pluto_zone_dist1,
    b.units_total        as pluto_units_total, 
    b.units_res          as pluto_units_res, 
    b.num_floors         as pluto_floors,
    b.year_built         as pluto_year_built, 
    b.lon_ctr            as pluto_lon_ctr, 
    b.lat_ctr            as pluto_lat_ctr, 
    b.radius             as pluto_radius, 
    b.parts              as pluto_parts, 
    b.points             as pluto_points,
    b.address            as pluto_address,
    b.owner_name         as pluto_owner,
    --
    -- Note about ACRIS columns:
    --
    --    - The 'docid' corresponds to the ACRIS record that was identified as 
    --      determining ownership.  Typically (about 90% of the time), this is a 
    --      deed transfer, but it could be a court order (CTOR), or a mortgage
    --      record, etc.
    --    - The 'doctype' is the corresponding doctype for that record, which
    --      specifies the type of "action" or "status update" that was found. 
    --    - The 'effdate' is simply the filing date for that record, which we
    --      call here the "effective date".
    --    - The 'mindate' is the date of the earliest ACRIS record of any kind 
    --      for this lot (which can be useful for when we have to say things like
    --      "no records before date X were found for this lot").
    --    - The remaining columns are as defined in the 'transfer_origin table. 
    --
    g.docid              as acris_docid,
    g.doctype            as acris_doctype,
    g.last_transfer      as acris_effdate,
    g.mindate            as acris_mindate,
    g.buyers             as acris_buyers,
    g.class              as acris_code, 
    g.whole              as acris_whole, 
    g.amount             as acris_amount, 
    g.name               as acris_owner_name, 
    g.address            as acris_owner_address,
    -- Placeholder column for number of declaration records 
    case when is_condo_bbl(a.bbl) then 1 else null end 
                         as condo_declare, 
    j.bank               as condo_parent,
    coalesce(h.contact,0)      as hpd_contact,
    coalesce(h.complaint,0)    as hpd_complaint,
    coalesce(h.violation,0)    as hpd_violation,
    coalesce(h.legal,0)        as hpd_legal
from omni.taxlot_origin     as a
left join push.pluto_taxlot as b on a.bbl = b.bbl
left join omni.stable_origin as d on a.bbl = d.bbl
left join meta.residential  as e on a.bbl = e.bbl
left join push.dcp_coop     as f on a.bbl = f.bbl
left join p2.acris_owner    as g on a.bbl = g.bbl
left join push.hpd_taxlot_summary as h on a.bbl = h.bbl
left join omni.dcp_condo_map as j on a.bbl = j.unit;



drop view if exists meta.building cascade;
create view meta.building as
select 
    a.bbl, 
    a.bin,
    b.doitt_id,
    b.lat_ctr,
    b.lon_ctr,
    b.radius,
    b.parts,
    b.points,
    a.in_adr,
    a.in_pluto,
    a.total_adr,
    a.total_pluto
from omni.building_origin     as a
left join push.pluto_building as b on (a.bbl,a.bin) = (b.bbl,b.bin);





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


drop view if exists meta.developer cascade;
create view meta.developer as
select a.bbl, a.devid, b.name
from      push.misc_dev_rel  as a
left join push.misc_dev_ent  as b on a.devid = b.id;

commit;

--
-- DEPRECATED
--
-- A crucial joining view that can be used to tell us everything we need
-- to know about either a building (given a BBL,BIN pair) -or- a taxlot
-- (if given just the BBL).  In the later case, you'll want to use a
-- "LIMIT 1" in the select, because of course (for multi-building lots)
-- all of the attributes will be redundant.
--
/*
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
*/

