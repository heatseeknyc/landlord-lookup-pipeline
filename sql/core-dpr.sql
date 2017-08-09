
begin;

-- An initial exploratory view of our flat table, so we can see 
-- what's inside.  Omits the polygon field and a few others (electoral
-- districts) we most likely won't be using.
drop view if exists core.dpr_park_tidy cascade;
create view core.dpr_park_tidy as 
select 
    gispropnum as gisnum,
    signname,
    typecatego as category,
    -- communityb,
    -- councildis,
    -- zipcode,
    borough as boro,
    acres, 
    address, 
    waterfront as water,
    substr(location,0,32) as location
from flat.dpr_park_prop;

-- And our normalized view, restricted to fields we'll be using.
-- Columns rename and typed as appropriate.
drop view if exists core.dpr_park_prop cascade;
create view core.dpr_park_prop as 
select 
    gispropnum as gisnum,
    borough::char(1) as boro,
    signname,
    typecatego as category,
    acres::float as acres, 
    address, 
    case when waterfront = 'Yes' then true else false end as water,
    location,
    the_geom as polygon
from flat.dpr_park_prop;

commit;

/*
  Observations/Issues:
   - GISPRONUM is always present and distinct, which is good.  let's make it our key.
   - 'the_geom' is always of the format 'MULTIPOLYGON(((...)))', which is also good
   - but it may (will likely) contain multiple parts
   - 'signname' is not distinct on the primary key, which is sad.
   - there are many instances of 'signname' occuring multiply for what should
     be a single park.  So apparently these are assemblages of taxlot polygons.
     Or may be completely different parks, incompletely named.
   - Then there are 117 entires named simply 'Park', 16 as 'Garden' and 4 as 'Lot'.
*/

