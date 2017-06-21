begin;

-- 45064 rows for the 2007-2015 version of this dataset.
-- There were are no structually invalid rows, but we keep the constraint
-- on kosher-ness in-place, on general principles (in case we get a different
-- version of this dataset in the future).  Note also thatapparently some 
-- 335 of these rows will nonetheless fail to match in Pluto 16v2.
--
-- 405576 rows
drop view if exists core.stable_joined cascade;
create view core.stable_joined as
select
  ucbbl as bbl,
  date_part('year',year) as year,
  unitcount, 
  case when estimate = 'Y' then true else false end as estimate,
  abatements
from flat.stable_joined_nocrosstab
where is_kosher_bbl(ucbbl);

-- Aggregate by BBL, selecting last year with non-zero unit count
-- (and restricting to BBLs with at least one year where that count is
-- present and non-zero), which drops some 257 rows.
-- 44807 rows 
drop view if exists core.stable_joined_maxyear cascade;
create view core.stable_joined_maxyear as
select bbl,max(year) as year from core.stable_joined
where unitcount > 0 group by bbl;

-- Our primary reference view for the taxbills dataset. 
-- Still 44807 rows, 335 of which won't match in Pluto. 
drop materialized view if exists core.stable_joined_lastyear cascade;
create materialized view core.stable_joined_lastyear as
select a.bbl, a.year, b.unitcount, b.estimate, b.abatements
from      core.stable_joined_maxyear as a
left join core.stable_joined         as b on a.bbl = b.bbl and a.year = b.year;
create index on core.stable_joined_lastyear(bbl);

-- Restricts the freshly loaded "flat" file kosher BBLs only, dropping
-- the 3 rows with broken block numbers + the catch-all "zombie" bbl (9999999999); 
-- Leaving 39927 rows total.
drop view if exists core.stable_dhcr2015_grouped;
create view core.stable_dhcr2015_grouped as
select * from flat.stable_dhcr2015_grouped
where is_kosher_bbl(bbl);

-- And finally row which tells us everything we know about a given BBL using both 
-- sources taken together.  The data still require interpretation, and still not 
-- every BBL is guaranteed to match valid Pluto (in fact, several hundred do not),
-- but at least we can compare the results side-by-side.
-- 47260 rows, of which 819 are outside Pluto.
drop view if exists core.stable_combined cascade;
create view core.stable_combined as
select 
  -- first the primary key
  coalesce(a.bbl,b.bbl) as bbl, 
  -- then the DHCR + taxbill columns, respectively. 
  -- note that the first column in each bunch also serves (via NULL/non-NULL status)
  -- as a boolean indicator of whether the BBL is present in that respective dataset
  -- or not.
  a.count      as dhcr_bldg_count, -- non-NULL iff row exists in DHCR
  a.has_421a   as dhcr_421a, 
  a.has_j51    as dhcr_j51, 
  a.special    as dhcr_special,
  b.year       as taxbill_lastyear, -- non-NULL iff row exists in taxbills
  b.unitcount  as taxbill_unitcount, 
  b.abatements as taxbill_abatements
from       core.stable_dhcr2015_grouped as a
full outer join core.stable_joined_lastyear as b on a.bbl = b.bbl; 


--
-- Deprecated Stuff
--

-- A restriction of the most recent taxbills rowset to just those tax lots 
-- having some kind of stability marking. 
drop view if exists core.stable_taxbill_2016Q4 cascade; 
create view core.stable_taxbill_2016Q4 as  
select bbl,unitcount,has_421a,has_j51
from flat.stable_taxbill
where year = 2016 and quarter = 4 and (has_421a or has_j51 or unitcount is not null);

commit;

