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
    bbl2type(coalesce(a.bbl,b.bbl)) as bbltype 
    bbl2qblock(coalesce(a.bbl,b.bbl)) as qblock
from omni.dcp_all as a
full outer join push.acris_legal_count as b on a.bbl = b.bbl;
create index on omni.taxlot_origin(bbl);


-- Some 296 illegal BBLs in the combined stabilizatin list!
create view omni.stable_orphan as
select a.* from push.stable_combined as a
left join omni.taxlot_origin as b on a.bbl = b.bbl where b.bbl is null;


-- A unified view of (BBL,BIN) tuples, across ADR + Pluto buildings.
-- If a (BBL,BIN) pair has any significance, theoretically it should be in here.
-- Yields 1185955 rows for PAD 17b and Pluto 16v2.
create table omni.building_origin as
select
    coalesce(a.bbl,b.bbl) as bbl,
    coalesce(a.bin,b.bin) as bin,
    a.bbl is not null as in_adr,   -- in push.dcp_pad_adr
    b.bbl is not null as in_pluto, -- in push.pluto_building
    bbl2type(coalesce(a.bbl,b.bbl)) as bbltype,
    bin2type(coalesce(a.bin,b.bin)) as bintype,
    a.total as total_adr,  -- count of distinct -features- (most likely); or possibly buildings
    b.total as total_pluto  -- count of distinct doitt_id's (hence, buildings)
from push.dcp_pad_keytup as a
full outer join push.pluto_keytup as b on (a.bbl,a.bin) = (b.bbl,b.bin);
create index on omni.building_origin(bbl);
create index on omni.building_origin(bin);
create index on omni.building_origin(bbl,bin);

commit;



-- PAD outer, less bank BBLs and condo units = 851574 rows
/*
select count(*) 
from push.dcp_pad_outer as a 
left join omni.dcp_condo_map as b on a.bbl = b.unit where b.unit is null and not is_condo_bbl(a.bbl); */
