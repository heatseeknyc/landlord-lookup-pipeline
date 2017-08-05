--
-- The "norm" schema contains what are (usually) final-form, normalized 
-- relations for consumption by the REST gateway and/or CSV export. 
--
-- In particular, while the REST gateway sometimes pulls from other schema, 
-- currently the (automated) CSV dumping -must- look in this schema for an 
-- object to pull.  This is slightly cumbersome, but useful as a constraint
-- in that it forces us to present a well-defined inteface (and naming scheme)
-- for what can be dumped and what not. 
--

begin;

drop schema if exists norm cascade; 
create schema norm;

create view norm.pluto_condo_primary as
select * from push.pluto_taxlot_tidy where is_condo_bbl(bbl) order by bbl;

--
-- Rent stabilization exports
--

-- Minus BBLs not present Pluto 16v2 (some 819 rows).
create view norm.stable_combined_restricted as
select a.* 
from      push.stable_combined as a
left join push.pluto_taxlot     as b on a.bbl = b.bbl where b.bbl is not null
order by bbl; 

-- Includes BBLs which are structurally valid not in Pluto, aka "orphans".
create view norm.stable_combined_withorphans as
select * from push.stable_combined
order by bbl; 

-- Now we derive the real, normalized range spec that PAD should have provided:
-- For every legitimate (that is "condo/bank") bill_bbl, we provide just the valid 
-- pairs of (lo,hi) BBLs that are themselves not condo/bank BBLs (and not out of sequence).
-- (Actually, a lo > hi case hasn't occured yet, but the check is there anyway just in case).
--
-- Also, we derive a 'depth' column reprenting the number of implied units in the given range.
--
-- Yields 247526 implied units across 7766 bank BBLs for version 17b. 
-- Note that this "sum" implies the ranges are not overlapping, which hasn't been verified
-- at this stage.  It's entirely possible that some ranges do overlap, so the real unit
-- total will may be a bit lower, after cross-checking. 
---
create view norm.dcp_condo_spec as
select lo_bbl, hi_bbl, bbl, bill_bbl, condoflag, condonum, coopnum,
    (1+(hi_bbl-lo_bbl))::integer as depth
from push.dcp_pad_bbl where is_condo_bbl(bill_bbl) and
    not (is_condo_bbl(lo_bbl) or is_condo_bbl(hi_bbl)) and lo_bbl <= hi_bbl
order by bill_bbl, lo_bbl, bbl;

create view norm.acris_declare_simple as
select bbl, docid, doctype from p0.acris_history where docfam = 5
order by bbl, docid, doctype;

create view norm.lpd_indiv_okname as
select * from push.lpc_indiv_okname order by bbl, bin, name;

commit;

