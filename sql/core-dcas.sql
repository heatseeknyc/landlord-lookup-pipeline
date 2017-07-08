
begin;

drop table if exists core.dcas_law48 cascade; 
create table core.dcas_law48 as
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
create index on core.dcas_law48(bbl);

create view core.dcas_law48_count as
select bbl, count(*) from core.dcas_law48 group by bbl; 

commit;

