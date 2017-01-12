--
-- Find properties in MAPPluto that aren't part of the taxbills dataset.
--
select a.bbl, a.address, a.owner_name, a.owner_type, a.year_built, a.num_floors, a.units_total
from core.pluto as a left join flat.taxbills as b on b.bbl = a.bbl 
where b.bbl is null order by a.bbl;
