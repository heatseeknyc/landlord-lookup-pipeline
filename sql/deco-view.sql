begin;

drop schema if exists deco cascade; 
create schema deco;

--
-- A final view on outgoing data which is basically equivalent to the table 
-- of the same name in the 'hard' schema, but with (verbose) reference data 
-- labels slotted in.  Doing it this way will should save substantial space,
-- with minimal time cost. 
--
-- DEPRECATED
/* create view deco.property_summary as
select 
    a.*, 
    a.residential_likely or a.stable_status is not null as residential,
    b.label as pluto_bldg_class_label, c.label as pluto_land_use_label
from hard.property_summary as a
left join push.pluto_refdata_bldgclass as b on a.pluto_bldg_class = b.tag
left join push.pluto_refdata_landuse as c on a.pluto_land_use = c.tag; */

create view deco.taxlot as
select
    a.*,
    b.label as pluto_land_use_label,
    c.label as pluto_bldg_class_label
from hard.taxlot as a
left join hard.pluto_refdata_landuse   as b on a.pluto_land_use = b.tag
left join hard.pluto_refdata_bldgclass as c on a.pluto_bldg_class = c.tag;


-- Just enough into to the display the "base lot" for a condo unit. 
create view deco.baselot as
select
    bbl,
    is_resi,
    pluto_address,
    pluto_points,
    pluto_parts,
    pluto_lon_ctr,
    pluto_lat_ctr,
    pluto_radius,
    pluto_year_built,
    pluto_units_res,
    pluto_bldg_count
from hard.taxlot as a;

commit;

