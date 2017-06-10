begin;

drop view if exists core.misc_joined cascade;
create view core.misc_joined as
select
  ucbbl as bbl,
  date_part('year',year) as year,
  unitcount, 
  case when estimate = 'Y' then true else false end as estimate,
  abatements
from flat.misc_joined_nocrosstab;

drop view if exists core.misc_joined_maxyear cascade;
create view core.misc_joined_maxyear as
select bbl,max(year) as year from core.misc_joined
where unitcount > 0 group by bbl;

-- A unified view of taxlots having confirmed stability markings across 
-- both data sources.  Current rowcount = 45261.
drop view if exists core.misc_stable_confirmed cascade; 
create view core.misc_stable_confirmed as
select 
  coalesce(a.bbl,b.bbl) as bbl, 
  a.has_421a or b.has_421a as has_421a,
  a.has_j51 or b.has_j51 as has_j51,
  b.unitcount, a.special,
  a.bbl is not null as in_dhcr,
  b.bbl is not null as in_taxbill
from flat.misc_dhcr2015 as a
full outer join core.misc_taxbill_2016Q4 as b on a.bbl = b.bbl; 

-- A restriction of the most recent taxbills rowset to just those tax lots 
-- having some kind of stability marking. 
drop view if exists core.misc_taxbill_2016Q4 cascade; 
create view core.misc_taxbill_2016Q4 as  
select bbl,unitcount,has_421a,has_j51
from flat.misc_taxbill
where year = 2016 and quarter = 4 and (has_421a or has_j51 or unitcount is not null);

drop view if exists core.misc_nycha cascade;
create view core.misc_nycha as
select 
  public.make_bbl(boroid,block,lot) as bbl,
  development, managed_by, house, street, 
  zipcode as zip5,
  case 
    when bin = 'Pending' then null
    else bin::integer 
  end as bin
from flat.misc_nycha;

drop view if exists core.misc_liensale cascade;
create view core.misc_liensale as
select * from flat.misc_liensale;

commit;

