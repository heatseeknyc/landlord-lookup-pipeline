
begin;

drop view if exists core.dof_rolling cascade;
create view core.dof_rolling as 
select
    make_bbl(borough,block,lot) as bbl,
    -- neighborhood,
    -- bldgclass_category,
    taxclass_present,
    taxclass_atsale,
    bldgclass_present,
    bldgclass_atsale,
    address,
    apartment,
    -- zipcode,
    -- units_resi, 
    -- units_comm, 
    -- units_total,
    -- sqft_land,
    -- sqft_gross,
    -- year_built smallint,
    easement,
    sale_price,
    sale_date
from flat.dof_rolling;

commit;

