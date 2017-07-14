
begin;

drop view if exists core.dcas_law48 cascade; 
create view core.dcas_law48 as
select
    make_bbl(boro,block,lot) as bbl,
    coordinates,
    date_created as created,
    pluto,
    address,
    parcel_name,
    agency,
    easements,
    proximity,
    irregular,  -- Y/N/null
    petroleum,  -- Yes/null
    edesig,
    ibz,
    zone1,
    zone2,
    overlay1,
    overlay2,
    sp1,
    sp2,
    potential_urban,
    current_uses 
from flat.dcas_law48;

create view core.dcas_law48_count as
select bbl, count(*), max(created) as latest 
from core.dcas_law48 group by bbl; 

create view core.dcas_law48_tidy as
select
    a.bbl, a.latest,
    b.coordinates, b.address, b.parcel_name, b.agency, b.easements 
from core.dcas_law48_count as a
left join core.dcas_law48  as b on (a.bbl,a.latest) = (b.bbl,b.created);

drop view if exists core.dcas_ipis cascade;
create view core.dcas_ipis as 
select
    bbl, 
    parcel_name,
    parcel_address,
    juris,
    agency,
    -- jurisdiction_description text,
    rpad,
    -- rpad_description text,
    waterfront as water,
    irregular as irreg, 
    owned_leased as owntype,
    num_bld as bldg_count, 
    floors, 
    pr_zone as zone_pr,
    ov_zone as zone_ov,
    sd_zone as zone_sd,
    case when urban_renewal_site = 'Y' then true else false end as renewal
    -- primary_use,
    -- final_commitment,
    -- agreeement,
from flat.dcas_ipis;

commit;

