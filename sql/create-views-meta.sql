begin;

--
-- First we construct two mutually exclusive rowsets.
--

-- The first result set that attempts to identify the "most important" polygon for 
-- a given BBL/BIN pair -- that is, the first non-degenerate tuple (going by doitt_id).
-- Somewhat imperfect in that there are about 344 BBLs with -only- degenerate BINs,
-- as of Pluto 16v2, and these lots will be entirely omitted from this result set.
create view meta.property_built as
select bbl, bin, min(doitt_id) as doitt_id, count(*) as total 
from push.buildings 
group by bbl,bin;
-- Note that we could "rescue" these 344 BBLs via a union on a separate query for 
-- that result set -- but that would be too much complexity for the time being.

-- A rowset of properties deemed "vacant" by appearing in the main Pluto attributes 
-- table, but not in the buildings shapefile set.  Presumably this represents the set
-- of all vacant lots (and parks without buildings) in the city. 
create view meta.property_vacant as
select a.bbl, b.bin, b.doitt_id, 0 as total 
from push.pluto as a
left join push.buildings as b on b.bbl = a.bbl 
where b.doitt_id is null;

create view meta.property_all as
select * from meta.property_built
union all
select * from meta.property_vacant;

-- Create a view on our initial buildings table restricted to the constraints 
-- above (and with a 'total' column appended reflecting the number of rowsets
-- in the original table having the BBL/BIN pair).  As a table, this rowset 
-- will have (bbl,bin) as a surrogate key to doitt_id.
create view meta.buildings_ideal as
select 
   a.bbl, a.bin, a.doitt_id, a.total,
   b.lat_ctr, b.lon_ctr, b.radius, b.parts, b.points
from meta.property_built as a
left join push.buildings as b on b.doitt_id = a.doitt_id;


-- These two views are analagous to the originals in the flat/push schema,
-- but purged of "rogue" BBL and BIN partial keys that can't be reliably 
-- joined on.  (The filtering is nearly the same in both joins; except the 
-- equality check in BBL isn't necessary in the registrations view, because 
-- this constraint is already enforced in the table it pulls from).

-- XXX move this to core
create view meta.registrations as
select * from push.registrations 
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

create view meta.nychpd as
select a.bbl, a.bin, count(distinct b.id) as contact_count, 1 as active
from      meta.registrations as a
left join push.contacts      as b on b.registration_id = a.id
group by a.bbl,a.bin;


--
-- A crucial joining view that presents everything we need for a given 
-- (BBL,BIN) pair.
--
create view meta.property_summary as
select 
  a.bbl, a.bin, cast(a.bbl/1000000000 as smallint) as boro, a.doitt_id, a.total as polygon_count,
  e.active as dhcr_active, 
  f.active as nychpd_active, f.contact_count,
  c.owner_name      as taxbill_owner_name,
  c.mailing_address as taxbill_owner_address,  
  b.land_use        as pluto_land_use,
  b.bldg_class      as pluto_bldg_class,
  b.condo_number    as pluto_condo_number,
  b.units_total     as pluto_units_total,
  b.bldg_count      as pluto_bldg_count,
  b.lon_ctr as pluto_lon_ctr,
  b.lat_ctr as pluto_lat_ctr,
  b.radius  as pluto_radius,
  b.points  as pluto_points,
  b.parts   as pluto_parts,
  d.lon_ctr as building_lon_ctr,
  d.lat_ctr as building_lat_ctr,
  d.radius  as building_radius,
  d.points  as building_points,
  d.parts   as building_parts
from meta.property_all   as a
left join push.pluto     as b on b.bbl = a.bbl
left join flat.taxbills  as c on c.bbl = a.bbl
left join push.buildings as d on d.bbl = a.bbl and d.bin = a.bin 
left join core.dhcr      as e on e.bbl = a.bbl and e.bin = a.bin
left join meta.nychpd    as f on f.bbl = a.bbl and f.bin = a.bin;
-- TODO: add columns block, lot, pluto_active, building_active


-- DEPRECATED
-- Equivalent to the above, but restricted to most crucial indicators 
-- (with with shorter column names) for more convenient browsing.
-- For troubleshooting only.
create view meta.property_summary_tidy as
select 
  bbl, bin, boro, 
  dhcr_active as dhcr, nychpd_active as nychpd, contact_count as contacts
from meta.property_summary;


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

