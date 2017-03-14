begin;

-- These two views are analagous to the originals in the flat/push schema,
-- but purged of "rogue" BBL and BIN partial keys that can't be reliably 
-- joined on.  (The filtering is nearly the same in both joins; except the 
-- equality check in BBL isn't necessary in the registrations view, because 
-- this constraint is already enforced in the table it pulls from).

-- create view meta.dhcr_tuples as
-- select * from flat.dhcr_tuples 
-- where 
--  bbl is not null and bbl >= 1000000000 and 
--  bin is not null and bin not in (0,1000000,2000000,3000000,4000000,5000000);

-- XXX move this to core
create view meta.registrations as
select * from push.registrations 
where 
  bbl is not null and 
  bin is not null and bin not in (0,1000000,2000000,3000000,4000000,5000000);

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
-- create view meta.dhcr_status as
-- select bbl,bin,1 as dhcr_active from meta.dhcr_tuples group by bbl,bin;

create view meta.nychpd as
select a.bbl, a.bin, count(distinct b.id) as contact_count, 1 as active
from      meta.registrations as a
left join push.contacts      as b on b.registration_id = a.id
group by a.bbl,a.bin;


--
-- A crucial joining view on the two above views.
--
-- Equivalent to a full outer join on the above two tables (but with the 
-- BBL/BIN keys coalesced on cases where they match in one  of the views but 
-- not the other).  Basically it tells us everything (of current interest) that 
-- the DHCR + NYCHPD datasets can tell us about a property for a given property 
-- (going by bbl/bin as a composite key, which may not be present in each
-- table separately).
--
-- create view meta.partial_summary as
-- select a.bbl, a.bin, a.dhcr_active, b.contact_count, b.nychpd_active
-- from      meta.dhcr_status         as a 
-- left join meta.registration_status as b on b.bbl = a.bbl and b.bin = a.bin
-- union
-- select b.bbl, b.bin, a.dhcr_active, b.contact_count, b.nychpd_active
-- from      meta.registration_status as b 
-- left join meta.dhcr_status         as a on a.bbl = b.bbl and a.bin = b.bin;


-- Finally, our big happy view that tells us everything we need to know
-- about a property given a combination of (BBL,BIN).  Feeds into the "hard"
-- table of the same name, which is consumed by our REST service.
create view meta.property_summary as
select 
  a.bbl, a.bin, cast(a.bbl/1000000000 as smallint) as boro_id,
  d.active as dhcr_active, 
  e.active as nychpd_active, e.contact_count,
  c.owner_name      as taxbill_owner_name,
  c.mailing_address as taxbill_owner_address,  
  c.active_date     as taxbill_active_date,
  b.owner_name      as pluto_owner_name,
  b.num_bldgs       as pluto_building_count,
  b.units_total     as pluto_units_total,
  b.lon_ctr as pluto_lon_ctr,
  b.lat_ctr as pluto_lat_ctr,
  b.radius  as pluto_radius,
  b.points  as pluto_points,
  b.parts   as pluto_parts,
  a.lon_ctr as building_lon_ctr,
  a.lat_ctr as building_lat_ctr,
  a.radius  as building_radius,
  a.points  as building_points,
  a.parts   as building_parts
from flat.buildings      as a
left join core.pluto     as b on b.bbl = a.bbl
left join flat.taxbills  as c on c.bbl = a.bbl
left join core.dhcr      as d on d.bbl = a.bbl and d.bin = a.bin
left join meta.nychpd    as e on e.bbl = a.bbl and e.bin = a.bin;


-- Equivalent to the above, but restricted to most crucial indicators 
-- (with with shorter column names) for more convenient browsing.
-- For troubleshooting only.
create view meta.property_summary_tidy as
select 
  bbl, bin, boro_id as boro, 
  dhcr_active as dhcr, nychpd_active as nychpd, contact_count as contacts
from meta.property_summary;


-- A deprecated form of the property_summary view
-- create view meta.property_summary_older as
-- select 
--  a.bbl, b.bin, cast(a.bbl/1000000000 as smallint) as boro_id,
--  b.dhcr_active, b.nychpd_active, b.contact_count,
--  a.owner_name      as taxbill_owner_name,
--  a.mailing_address as taxbill_owner_address,
--   a.active_date     as taxbill_active_date
-- from      flat.taxbills        as a 
-- left join meta.partial_summary as b on b.bbl = a.bbl;


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

