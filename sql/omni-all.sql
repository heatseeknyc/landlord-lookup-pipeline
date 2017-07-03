--
-- The lovely new omni source
--

begin;

create table omni.dcp_condo_map as
select * from flat.dcp_condo_map;
create index on omni.dcp_condo_map(bank);
create index on omni.dcp_condo_map(unit);

-- All lots in PAD (expressed or implied) = 1106866 rows.
create table omni.dcp_all as
select 
    coalesce(a.bbl,b.unit) as bbl,
    a.in_bbl as in_pad_bbl,
    a.in_adr as in_pad_adr,
    a.bbl is not null as in_outer,
    b.unit is not null as in_condo 
from push.dcp_pad_outer as a
full outer join omni.dcp_condo_map as b on a.bbl = b.unit; 
create index on omni.dcp_all(bbl);

-- A truly unified view of all BBLs in the ecosystem.
create table omni.taxlot_origin as
select 
    coalesce(a.bbl,b.bbl) as bbl,
    a.in_pad_bbl, 
    a.in_pad_adr, 
    a.in_outer as in_pad_outer,
    a.in_condo as in_pad_condo,
    a.bbl is not null as in_pad,
    b.bbl is not null as in_acris,
    qualify_bbl(coalesce(a.bbl,b.bbl)) as qualify
from omni.dcp_all as a
full outer join push.acris_legal_count as b on a.bbl = b.bbl;
create index on omni.taxlot_origin(bbl);

commit;



-- PAD outer, less bank BBLs and condo units = 851574 rows
/*
select count(*) 
from push.dcp_pad_outer as a 
left join omni.dcp_condo_map as b on a.bbl = b.unit where b.unit is null and not is_condo_bbl(a.bbl); */
