begin;

-- A final view on outgoing data which is basically equivalent to the table 
-- of the same name in the 'hard' schema, but with (verbose) reference data 
-- labels slotted in.  Doing it this way will should save substantial space,
-- with minimal time cost. 
create view deco.property_summary as
select a.*, b.label as pluto_bldg_class_label, c.label as pluto_land_use_label
from hard.property_summary as a
left join push.pluto_refdata_bldgclass as b on a.pluto_bldg_class = b.tag
left join push.pluto_refdata_landuse as c on a.pluto_land_use = c.tag;

commit;
