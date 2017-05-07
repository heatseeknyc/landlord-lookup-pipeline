begin;

-- A restriction of the most recent taxbills rowset to just those tax lots 
-- having some kind of stability marking. 
create view core.taxbill_stable_2016Q4 as  
select bbl,unitcount,has_421a,has_j51
from flat.taxbills 
where year = 2016 and quarter = 4 and (has_421a or has_j51 or unitcount is not null);

-- A unified view of taxlots having stability markings across both data sources.
-- Current rowcount = 45261.
create view core.stable as
select 
  coalesce(a.bbl,b.bbl) as bbl, 
  a.has_421a or b.has_421a as has_421a,
  a.has_j51 or b.has_j51 as has_j51,
  b.unitcount, a.special,
  a.bbl is not null as in_dhcr,
  b.bbl is not null as in_taxbills
from flat.dhcr2015 as a
full outer join core.taxbill_stable_2016Q4 as b on a.bbl = b.bbl; 

commit;

