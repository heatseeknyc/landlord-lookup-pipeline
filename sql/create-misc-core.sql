
begin;

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

