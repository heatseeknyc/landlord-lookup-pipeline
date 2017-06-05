begin;

drop view if exists meta.nychpd_count cascade;
drop view if exists meta.property_summary cascade;
drop view if exists meta.contact_simple cascade;
drop view if exists meta.contact_info cascade;
drop view if exists meta.residential cascade;

create view meta.nychpd_count as
select a.bbl, a.bin, count(distinct b.id) as total
from      push.nychpd_registration as a
left join push.nychpd_contact      as b on b.registration_id = a.id
group by a.bbl,a.bin;

-- A magical view which (portends to) tell us whether a given property 
-- is residential or not (via the derived 'status' flag).  There's still
-- some room for improvement with this determination, but it's probably
-- good enough for now.
create view meta.residential as
select
  coalesce(a.bbl,b.bbl) as bbl,
  a.units_res       as units_res,
  a.condo_number    as condo_number,
  a.bldg_count      as pluto_building_count,
  b.building_count  as nychpd_building_count,
  a.bbl is not null as in_pluto,
  b.bbl is not null as in_nychpd,
  a.units_res > 0 or a.condo_number > 0 or b.bbl is not null
       as status 
from push.pluto_taxlot as a
full outer join push.nychpd_building_count as b on b.bbl = a.bbl;

--
-- A crucial joining view that can be used to tell us everything we need
-- to know about either a building (given a BBL,BIN pair) -or- a taxlot
-- (if given just the BBL).  In the later case, you'll want to use a
-- "LIMIT 1" in the select, because of course (for multi-building lots)
-- all of the attributes will be redundant.
--
create view meta.property_summary as
select 
  a.bbl, b.bin, b.doitt_id, 
  a.land_use        as pluto_land_use,
  a.bldg_class      as pluto_bldg_class,
  a.condo_number    as pluto_condo_number,
  a.units_total     as pluto_units_total,
  a.bldg_count      as pluto_bldg_count,
  a.address         as pluto_address,
  public.bbl2boroname(a.bbl) as pluto_borough,
  a.lon_ctr as pluto_lon_ctr,
  a.lat_ctr as pluto_lat_ctr,
  a.radius  as pluto_radius,
  a.points  as pluto_points,
  a.parts   as pluto_parts,
  c.lon_ctr as building_lon_ctr,
  c.lat_ctr as building_lat_ctr,
  c.radius  as building_radius,
  c.points  as building_points,
  c.parts   as building_parts,
  d.bbl is not null as stable_status,
  d.has_421a  as stable_421a,
  d.has_j51   as stable_j51,
  d.unitcount as stable_units,
  d.special   as stable_flags,
  d.in_dhcr   as stable_dhcr,
  coalesce(e.total,0) as nychpd_count,
  g.status    as residential
from      push.pluto_taxlot           as a 
left join push.pluto_building_canonical as b on a.bbl = b.bbl
left join push.pluto_building         as c on b.bbl = c.bbl and b.doitt_id = c.doitt_id
left join push.misc_stable            as d on a.bbl = d.bbl
left join meta.nychpd_count           as e on b.bbl = e.bbl and b.bin = e.bin
left join meta.residential            as g on a.bbl = g.bbl;



--
-- The next two view feed into the "contact_info" view in this schema
-- (and into the "hard" table of the same name).
--

-- A simplified view of push.contacts with some column names, other columns 
-- catenated for brevity / tidier reporting (and minus contact_title), and the
-- ordering rank for contact_type slotted in.
create view meta.contact_simple as 
select 
  a.id as contact_id, registration_id, a.contact_type, b.id as contact_rank, 
  contact_description as description, corporation_name as corpname, 
  public.make_contact_name(contact_first_name,contact_middle_initial,contact_last_name) as contact_name,
  public.make_contact_addr(
    business_house_number,business_street_name,business_apartment,business_city,business_state,business_zip
  ) as business_address 
from push.nychpd_contact           as a
left join push.nychpd_contact_rank as b on b.contact_type = a.contact_type;

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
create view meta.contact_info as
select 
  a.id as registration_id, bin, bbl, building_id, last_date, end_date,
  b.contact_id, b.contact_type, b.contact_rank, b.description, 
  b.corpname, b.contact_name, b.business_address
from push.nychpd_registration  as a
left join meta.contact_simple as b on b.registration_id = a.id;

commit;

