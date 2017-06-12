
begin;

drop view if exists temp.retro cascade; 
create view temp.retro as 
select a.bbl, a.year, b.year as prev1, c.year as prev2
from      flat.liensales as a
left join flat.liensales as b on b.bbl = a.bbl and b.year+1 = a.year
left join flat.liensales as c on c.bbl = a.bbl and c.year+2 = a.year; 

drop view if exists temp.forsale cascade; 
create view temp.forsale as 
select 
  a.bbl, a.year, a.taxclass, b.owner_type, b.bldg_count,
  b.bldg_class, b.land_use, b.condo_number,
  b.units_total, b.units_res, c.unitcount, 
  case 
    when unitcount is null then units_total 
    when units_total > unitcount then units_total 
    else unitcount 
  end as units,
  case 
    when unitcount is null then 0 
    else unitcount 
  end as stable, 
  c.estimated, c.amount, b.comm_dist, b.council, d.prev1, d.prev2
from flat.liensales a, push.pluto b, temp.taxbills c, temp.retro d
where 
  a.bbl = b.bbl and a.bbl = c.bbl and 
  a.year = c.year+1 and c.quarter = 4 and
  a.bbl = d.bbl and a.year = d.year;

drop view if exists temp.atrisk cascade; 
create view temp.atrisk as 
select 
  a.*, 
  case when a.units > 0 
  then (a.amount / a.units) / 500
  else null 
  end as risk,
  -- yes, there are better ways to do this mapping.
  -- but this will work for now.
  case 
    when a.prev1 is not null and a.prev2 is not null then 2
    when a.prev1 is not null or a.prev2 is not null then 1 
    else 0
  end as past
from temp.forsale 
as a;


-- A list of "phantom taxlots", whose tax bills indiciate credits for  
-- stabiilized housing, even though it appears the lot is either vacant,
-- or a parking lot.
drop table if exists temp.phantom_taxlots;
create table temp.phantom_taxlots ( 
    bbl bigint PRIMARY KEY
);
insert into temp.phantom_taxlots (bbl) values 
    (2028570024),
    (2036270001)
;

-- Our actual set of endangered taxlots - defined as those haing 
-- some presence of stabilized units, and not in our list of phantom lots.
drop view if exists temp.endangered_taxlots cascade; 
create view temp.endangered_taxlots as 
select * from temp.atrisk
where unitcount > 0 and bbl not in (select bbl from temp.phantom_taxlots);

-- And our set of endangered buildings.  We denormalize on the 'bldg_count',
-- 'comm_dist' and 'council' columns for ease of access (to avoid the necessity of a join).o
drop view if exists temp.endangered_buildings cascade; 
create view temp.endangered_buildings as 
select 
    a.bbl, b.bin, a.bldg_count, a.comm_dist, a.council, 
    b.lat_ctr, b.lon_ctr, b.radius, b.parts, b.points
from temp.endangered_taxlots as a
left join push.buildings as b on a.bbl = b.bbl;



-- depreated
-- A somewhat tidier version of the above, with shorter column names
drop view if exists temp.turbo cascade; 
create view temp.turbo as 
select 
  bbl, taxclass, owner_type as owner, bldg_count as count, 
  bldg_class as bldg, land_use as land, condo_number as condo, 
  units_total as utotal, units_res as resid, unitcount as stable, estimated, amount,
  comm_dist as dist, council, prev1, prev2
from temp.forsale
where year = 2017;

-- Lots in Pluto that aren't part of JK's June 2016 taxbills set. 
drop view if exists temp.pluto_outliers;
create view temp.pluto_outliers as 
select a.bbl, a.address, a.owner_type, a.land_use, a.bldg_class, a.year_built, a.num_floors, a.units_total, a.condo_number, a.bldg_count
from push.pluto as a left join flat.taxbills as b on b.bbl = a.bbl 
where b.bbl is null order by a.bbl;

drop table if exists temp.missing;
create table temp.missing ( 
    bbl bigint PRIMARY KEY
);

commit;

