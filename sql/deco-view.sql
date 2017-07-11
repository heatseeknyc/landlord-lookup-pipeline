begin;

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

drop view if exists deco.taxlot cascade; 
create view deco.taxlot as
select
    a.*,
    coalesce(b.label,"no description available") as pluto_land_use_label,
    coalesce(c.label,"no description available") as pluto_bldg_class_label
from hard.taxlot as a
left join hard.pluto_refdata_landuse   as b on a.pluto_land_use = b.tag
left join hard.pluto_refdata_bldgclass as c on a.pluto_bldg_class = c.tag;

commit;

