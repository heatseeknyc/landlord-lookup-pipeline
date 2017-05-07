begin;

-- These two views are analagous to the originals in the flat/push schema,
-- but purged of "rogue" BBL and BIN partial keys that can't be reliably 
-- joined on.  (The filtering is nearly the same in both joins; except the 
-- equality check in BBL isn't necessary in the registrations view, because 
-- this constraint is already enforced in the table it pulls from).

-- XXX move this to core
create view meta.nychpd_registration as
select * from push.nychpd_registration 
where 
  bbl is not null and bbl >= 1000000000 and bbl < 6000000000 and
  bin is not null and bin >= 1000000 and bin not in (1000000,2000000,3000000,4000000,5000000);

--
-- The following two views are simple aggregations that tell us what we need
-- to know about a given property from the DHCR and HPD data sets respectively,
-- given a composite key (BBL,BIN), and feed into the 'partial_summary' view
-- defined below.
--
-- The "_active" flags are slotted in to make the query syntax in the 
-- 'partial_summary' view a bit simpler (even though they would of course be 
-- superfluous for these views, considered in isolation). 
--

create view meta.nychpd_count as
select a.bbl, a.bin, count(distinct b.id) as total
from      meta.nychpd_registration as a
left join push.nychpd_contact      as b on b.registration_id = a.id
group by a.bbl,a.bin;


--
-- A crucial joining view that presents everything we need for a given 
-- (BBL,BIN) pair.
--
create view meta.property_summary as
select 
  a.bbl, b.bin, b.doitt_id, 
  a.land_use        as pluto_land_use,
  a.bldg_class      as pluto_bldg_class,
  a.condo_number    as pluto_condo_number,
  a.units_total     as pluto_units_total,
  a.bldg_count      as pluto_bldg_count,
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
  d.has_421a  as stable_421a,
  d.has_j51   as stable_j51,
  d.unitcount as stable_units,
  d.special   as stable_flags,
  coalesce(e.total,0) as nychpd_count
from      push.pluto_taxlot           as a 
left join push.pluto_building_primary as b on a.bbl = b.bbl
left join push.pluto_building         as c on b.bbl = c.bbl and b.doitt_id = c.doitt_id
left join push.stable                 as d on a.bbl = d.bbl
left join meta.nychpd_count           as e on b.bbl = e.bbl and b.bin = e.bin;



--
-- The next two view feed into the "contact_info" view in this schema
-- (and into the "hard" table of the same name).
--

-- A simplified view of push.contacts with some column names, other columns 
-- catenated for brevity / tidier reporting (and minus contact_title), and the
-- ordering rank for contact_type slotted in.
create view meta.contacts_simple as 
select 
  a.id as contact_id, registration_id, a.contact_type, b.id as contact_rank, 
  contact_description as description, corporation_name as corpname, 
  public.make_contact_name(contact_first_name,contact_middle_initial,contact_last_name) as contact_name,
  public.make_contact_addr(
    business_house_number,business_street_name,business_apartment,business_city,business_state,business_zip
  ) as business_address 
from push.contacts               as a
left join push.contact_rank as b on b.contact_type = a.contact_type;

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
from meta.registrations        as a
left join meta.contacts_simple as b on b.registration_id = a.id;

commit;

