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

create view norm.acris_control as select * from flat.acris_control;
create view norm.acris_condo_maybe as 
select bbl, history_count, docid_count
from p1.acris_condo_maybe order by bbl;

create view norm.pluto_condo_primary as
select * from push.pluto_taxlot_tidy where is_condo_primary(bbl) order by bbl;

create view norm.acris_declare as
select * from p1.acris_history where doctype = 'DECL' order by bbl, date_filed desc;

--
-- Rent stabilization exports
--

-- Minus BBLs not present Pluto 16v2 (some 819 rows).
create view norm.stable_confirmed_restricted as
select a.* 
from      push.stable_confrimed as a
left join push.pluto_taxlot     as b on a.bbl = b.bbl where b.bbl is not null
order by bbl; 

-- Includes BBLs which are structurally valid not in Pluto, aka "orphans".
create view norm.stable_confirmed_withorphans as
select * from push.stable_confrimed 
order by bbl; 

commit;



