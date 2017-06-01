begin;

-- A restriction of the most recent taxbills rowset to just those tax lots 
-- having some kind of stability marking. 
create view core.misc_taxbill_2016Q4 as  
select bbl,unitcount,has_421a,has_j51
from flat.misc_taxbill
where year = 2016 and quarter = 4 and (has_421a or has_j51 or unitcount is not null);

-- A unified view of taxlots having stability markings across both data sources.
-- Current rowcount = 45261.
create view core.misc_stable as
select 
  coalesce(a.bbl,b.bbl) as bbl, 
  a.has_421a or b.has_421a as has_421a,
  a.has_j51 or b.has_j51 as has_j51,
  b.unitcount, a.special,
  a.bbl is not null as in_dhcr,
  b.bbl is not null as in_taxbills
from flat.misc_dhcr2015 as a
full outer join core.misc_taxbill_2016Q4 as b on a.bbl = b.bbl; 

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

-- Redirects to the 'flat' datasets.
create view core.misc_joined as
select * from flat.misc_joined;

create view core.misc_liensale as
select * from flat.misc_liensale;

commit;

