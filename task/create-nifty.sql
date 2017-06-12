begin;

drop view if exists meta.spiffy cascade;
create view meta.spiffy as
select 
  a.bbl, b.bin, 
  b.lat_ctr, b.lon_ctr
from      flat.taxbills  as a 
left join flat.buildings as b on b.bbl = a.bbl;

drop view if exists meta.nifty cascade;
create view meta.nifty as
select 
  a.bbl, a.bin, cast(a.bbl/1000000000 as smallint) as boro_id,
  d.dhcr_active, d.nychpd_active, d.contact_count,
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
left join meta.partial_summary as d on d.bbl = a.bbl;

commit;

