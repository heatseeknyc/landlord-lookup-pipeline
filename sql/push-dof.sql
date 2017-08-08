
begin;

create table push.dof_rolling as
select * from core.dof_rolling;
create index on push.dof_rolling(bbl);
create index on push.dof_rolling(sale_date);

create view push.dof_rolling_tidy as
select 
    bbl, 
    taxclass_atsale as taxclass, 
    bldgclass_atsale as bldgclass,
    address,
    apartment as apt,
    easement as ease,
    sale_price, 
    sale_date  
from push.dof_rolling;

create table push.dof_rolling_count as
select bbl, max(sale_date), count(*) as total
from push.dof_rolling group by bbl;
create index on push.dof_rolling_count(bbl);

commit;

