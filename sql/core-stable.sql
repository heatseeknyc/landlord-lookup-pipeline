begin;

drop view if exists core.stable_joined cascade;
create view core.stable_joined as
select
  ucbbl as bbl,
  date_part('year',year) as year,
  unitcount, 
  case when estimate = 'Y' then true else false end as estimate,
  abatements
from flat.stable_joined_nocrosstab;

drop view if exists core.stable_joined_maxyear cascade;
create view core.stable_joined_maxyear as
select bbl,max(year) as year from core.stable_joined
where unitcount > 0 group by bbl;

drop view if exists core.stable_joined_lastyear cascade;
create view core.stable_joined_lastyear as
select a.bbl, a.year, b.unitcount, b.estimate, b.abatements
from      core.stable_joined_maxyear as a
left join core.stable_joined         as b on a.bbl = b.bbl and a.year = b.year;

drop view if exists core.stable_confirmed cascade;
create view core.stable_confirmed as
select 
  coalesce(a.bbl,b.bbl) as bbl, 
  b.year, b.unitcount, b.abatements,
  a.count as bldg_count, a.has_421a, a.has_j51, a.special,
  a.bbl is not null as in_dhcr,
  b.bbl is not null as in_taxbill
from       flat.stable_dhcr2015_grouped as a
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

-- A unified view of taxlots having confirmed stability markings across 
-- both data sources.  Current rowcount = 45261.
drop view if exists core.stable_stable_deprecated cascade;
create view core.stable_stable_deprecated as
select 
  coalesce(a.bbl,b.bbl) as bbl, 
  a.has_421a or b.has_421a as has_421a,
  a.has_j51 or b.has_j51 as has_j51,
  b.unitcount, a.special,
  a.bbl is not null as in_dhcr,
  b.bbl is not null as in_taxbill
from flat.stable_dhcr2015_grouped as a
full outer join core.stable_taxbill_2016Q4 as b on a.bbl = b.bbl; 

commit;

