--
-- The lovely new omni source
--

begin;

drop table if exists omni.dcp_condo_map cascade; 
create table omni.dcp_condo_map as
select * from flat.dcp_condo_map;
create index on omni.dcp_condo_map(bank);
create index on omni.dcp_condo_map(unit);

-- All lots in PAD (expressed or implied) = 1106866 rows.
drop table if exists omni.dcp_all cascade; 
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
drop table if exists omni.taxlot_origin cascade; 
create table omni.taxlot_origin as
select 
    coalesce(a.bbl,b.bbl) as bbl,
    a.in_pad_bbl, 
    a.in_pad_adr, 
    a.in_outer as in_pad_outer,
    a.in_condo as in_pad_condo,
    a.bbl is not null as in_pad,
    b.bbl is not null as in_acris,
    bbl2type(coalesce(a.bbl,b.bbl)) as bbltype,
    bbl2qblock(coalesce(a.bbl,b.bbl)) as qblock
from omni.dcp_all as a
full outer join push.acris_legal_count as b on a.bbl = b.bbl;
create index on omni.taxlot_origin(bbl);


-- Some 296 illegal BBLs in the combined stabilizatin list!
drop view if exists omni.stable_orphan cascade; 
create view omni.stable_orphan as
select a.* from push.stable_combined as a
left join omni.taxlot_origin as b on a.bbl = b.bbl where b.bbl is null;


-- A unified view of (BBL,BIN) tuples, across ADR + Pluto buildings.
-- If a (BBL,BIN) pair has any significance, theoretically it should be in here.
-- Yields 1185955 rows for PAD 17b and Pluto 16v2.
drop table if exists omni.building_origin cascade; 
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

drop table if exists omni.building_count cascade; 
create table omni.building_count as
select bbl,count(*) as total from omni.building_origin group by bbl;
create index on omni.building_count(bbl);

commit;


--
-- Newer stuff
--

begin;

create view omni.dcas_law48_orphan as
select a.* 
from push.dcas_law48 as a
left join hard.taxlot as b on a.bbl = b.bbl where b.bbl is null;


--
-- HPD v. PAD/Pluto, ACRIS
-- 

-- (BBL,BBN) pairs in HPD but not in PAD/Pluto 
-- 7647 rows (across 6110 BBLs)
create view omni.hpd_building_extra as
select a.*
from      push.hpd_building_program as a
left join omni.building_origin      as b on (a.bbl,a.bin) = (b.bbl,b.bin) 
    where b.bbl is null and b.bin is null;

-- Restriction of BBLs in the above set to those not in PAD/PLuto,
-- That is, lots under HPD jurisdiction but not in PAD/Pluto.
-- 1748 rows
create view omni.hpd_building_badlot as
select a.bbl from
(select distinct(bbl) from push.hpd_building_program) as a 
left join omni.building_count as b on a.bbl = b.bbl where b.bbl is null;

-- Finally, true stragglers in either PAD/Pluto nor ACRIS.
-- 422 rows
create view omni.hpd_building_stragglers as
select a.bbl 
from      omni.hpd_building_badlot as a
left join push.acris_legal_count   as b on a.bbl = b.bbl where b.bbl is null;

commit;



--
-- Stabilization
--

begin;

drop view if exists omni.stable_likely cascade;
create view omni.stable_likely as
select bbl from push.pluto_taxlot where units_res >= 6 and year_built < 1974;

commit;

