begin;

drop table if exists push.lpc_indiv cascade;
create table push.lpc_indiv as select * from core.lpc_indiv; 
create index on push.lpc_indiv(bbl);
create index on push.lpc_indiv(bin);
create index on push.lpc_indiv(bbl,bin);

-- 36680 rows, some 4520 with names > 1 (July 2017)
drop table if exists push.lpc_indiv_count cascade;
create table push.lpc_indiv_count as
select bbl, bin, count(*) as total, count(distinct lmk_name) as names
from push.lpc_indiv group by bbl, bin;
create index on push.lpc_indiv_count(bbl,bin);

drop view if exists push.lpc_indiv_block cascade;
create view push.lpc_indiv_block as 
select a.bbl, a.bin, total, names, b.lmk_name, b.pluto_addr
from push.lpc_indiv_count as a
left join push.lpc_indiv  as b on (a.bbl,a.bin) = (b.bbl,b.bin);

-- A counting table of all the distinct lmkname -markings- per BBL/BIN (that is, 
-- relations from BBL/BIN to lmkname).  Because many of these are useless historic 
-- district names (and because we couldn't think of any non-awkward names for 
-- this particular aggreagation) -- and because it's a temp table, anyway -- 
-- we chose the name below. 
drop table if exists push.lpc_indiv_badname cascade;
create table push.lpc_indiv_badname as 
select bbl, bin, lmk_name as name, count(*) as total 
from push.lpc_indiv group by bbl, bin, lmk_name;
create index on push.lpc_indiv_badname(bbl,bin);

-- A much smaller aggregation of relations, restricted to more plausible 
-- individual building/taxlot names.  Will still require manual curation,
-- but be much more focused and manageable.
create view push.lpc_indiv_okname as
select * from push.lpc_indiv_badname where name !~ 'Historic.District'; 

commit;


/*
-- 3007 rows, some 326 with lmk_name ~ '\)$';  
drop view if exists push.lpc_clean cascade;
create view push.lpc_clean as
select * from push.lpc_indiv where lmk_name !~ '^.*District'  and lmk_name !~ '^\d';

-- 2164 rows
drop view if exists push.lpc_clean_count cascade;
create view push.lpc_clean_count as
select bbl, bin, count(*) as total, count(distinct lmk_name) as names
from push.lpc_clean group by bbl, bin;
*/


