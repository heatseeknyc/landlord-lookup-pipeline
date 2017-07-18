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

-- A unified view of all "resonably legit" BBLs in the system.
-- Includes all BBLs from PAD/Pluto, and all "regular" BBLs from ACRIS.
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
full outer join p2.acris_history_count as b on a.bbl = b.bbl;
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

-- Buildings in Pluto that are "likely" to be stablized, according to EPTA criteria. 
-- Will overlap very strongly with the DHCR/Taxbill lists, but also contain about 13k
-- taxlots not in either of those result sets.
-- 55382 rows
drop view if exists omni.stable_likely cascade;
create view omni.stable_likely as
select bbl from push.pluto_taxlot where units_res >= 6 and year_built < 1974;

--
-- A combined view of stabilization across (DHCR, Taxbills, and "Pluto-likely"). 
-- Which we call the "classic" view first because it represents our older (pre-HPD)  
-- model for aggregation, and because (in theory) most of the markings in this 
-- dataset are for "classic", pre-1974 buildings.
--
-- In any case it's just an outer join of those 3 sets (2 of which are already joined 
-- in the "stable_combined" table), providing a crucial 'stable' flag defined as follows:
--
--    'confirmed' if at least one of the properties  on the lot is on the DHCR list, 
--     the taxlot has non-zero unitcounts (in the taxbill scrapes) through 2015.
--
--    'disputed' if the lot has no buildings on the DHCR list, and its last year 
--     of appearance is before 2015.  (Implicating being it likely was stabilized
--     in the past, but may no longer have stabilized units).
--
--     'possible' if neither of the above criteria are met, but the property meets
--     generic criteria for stabilization (pre-1974, 6 or more units),
--
-- A couple of notes as to the above:
--
--   - Due to the logic of how this table is constructed, every row will have
--     on of the above 3 values (i.e. there will be no rows with NULL status).
--
--   - So it shows up as NULL in a left join, that means the lot was most likely
--     never stabilized.
--
--   - Some of the above flags have different definitions in other rowsets.
--     For example, presence in the 'stable_likely' view (which the select for
--     this view pulls from) simply means that the tax lot meets pre-1974 criteria; 
--     whereas in this view it means that it meets those criteria, -and- is not 
--     otherwise 'confirmed' or 'disputed'.
--
-- 61415 rows
drop view if exists omni.stable_classic cascade;
create view omni.stable_classic as
select
  coalesce(a.bbl,b.bbl) as bbl,
  a.taxbill_lastyear,
  a.taxbill_unitcount,
  a.taxbill_abatements,
  a.dhcr_bldg_count,
  a.dhcr_421a,
  a.dhcr_j51,
  a.dhcr_special,
  case
    when a.dhcr_bldg_count > 0 or a.taxbill_lastyear = 2015 then 1 -- confirmed
    when a.taxbill_lastyear < 2015 then 2 -- disputed
    when b.bbl is not null then 3 -- possible
  end as status
from            push.stable_combined  as a
full outer join omni.stable_likely    as b on a.bbl = b.bbl; 


-- 
-- And our final, "origin" view for rent stabilization.
-- In which the 'status' flag denotes both designation and provenance in a  
-- meaningful way (with HPD taking precedence in some 67 rows, as of June 2017).
--
-- 62023 rows
drop view if exists omni.stable_origin cascade;
create view omni.stable_origin as
select
  coalesce(a.bbl,b.bbl) as bbl,
  a.taxbill_lastyear,
  a.taxbill_unitcount,
  a.taxbill_abatements,
  a.dhcr_bldg_count,
  a.dhcr_421a,
  a.dhcr_j51,
  a.dhcr_special,
  b.program as hpd_program,
  case
    when b.program = '7A' then 7
    when b.program = 'M-L' then 8 
    when b.program = 'NYCHA' then 9 
    when b.program = 'LOFT LAW' then 10 
    when b.program = 'OTHER' then 11 
    else a.status
  end as status
from            omni.stable_classic     as a
full outer join push.hpd_taxlot_program as b on a.bbl = b.bbl
    where a.bbl is not null or b.program is not null;


-- And a simple lookup table for the 'status' flag defined above.
-- This is something of a DRY violation of course, and will have to be 
-- maintained as our status designations inevitably change, moving foward.
-- But is much simpler than attempting any kind of automatic derivation. 
drop table if exists omni.label_status cascade;
create table omni.label_status ( 
    status integer,
    label text
);
insert into omni.label_status (status, label) values 
    (1,'confirmed'), (2,'disputed'), (3,'possible'), 
    (7,'7A'), (8,'M-L'), (9,'NYCHA'), (10,'LOFT LAW'), (11,'OTHER');
create index on omni.label_status(status);

commit;

