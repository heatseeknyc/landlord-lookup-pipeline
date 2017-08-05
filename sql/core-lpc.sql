
begin;

-- Selects fields of interests (renaming a few), and discards about 
-- 100 rows with degenerate BBLs, and 14 with null/invalid BBLs (mid-2017).
-- 47390 rows
drop view if exists core.lpc_indiv cascade;
create view core.lpc_indiv as 
select 
    bbl, bin, 
    objectid as object_id, 
    lp_number as lmk_id, 
    lm_name   as lmk_name, 
    pluto_addr,
    desig_addr,
    lm_type as lmk_type,
    hist_distr,
    boundaries,
    most_curre,
    case
        when status in ('CALENDARED','DESIGNATED') then status
        else 'NOT DESIGNATED'
    end as status,
    -- last_actio as last_action, 
    -- stat_not as status_note,
    -- count_bldg as bldg_count,
    non_bldg as nonbldg,
    vacant_lot as vacant,
    second_bldg as bldg2
from flat.lpc_indiv where is_valid_bbl(bbl) and not is_degenerate_bbl(bbl);


-- 36680 rows, some 4520 with names > 1
drop view if exists core.lpc_indiv_count cascade;
create view core.lpc_indiv_count as
select bbl, bin, count(*) as total, count(distinct lmk_name) as names
from core.lpc_indiv group by bbl, bin;

drop view if exists core.lpc_indiv_block cascade;
create view core.lpc_indiv_block as 
select a.bbl, a.bin, total, names, b.lmk_name, b.pluto_addr
from core.lpc_indiv_count as a
left join core.lpc_indiv  as b on (a.bbl,a.bin) = (a.bbl,b.bin);

-- 3007 rows, some 326 with lmk_name ~ '\)$';  
drop view if exists core.lpc_clean cascade;
create view core.lpc_clean as
select * from core.lpc_indiv where lmk_name !~ '^.*District'  and lmk_name !~ '^\d';

-- 2164 rows
drop view if exists core.lpc_clean_count cascade;
create view core.lpc_clean_count as
select bbl, bin, count(*) as total, count(distinct lmk_name) as names
from core.lpc_clean group by bbl, bin;

commit;

