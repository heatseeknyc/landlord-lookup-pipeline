begin;

drop schema if exists t1 cascade;
create schema t1;

-- This join basically represents ACRIS the way it's "meant" to be viewed -- 
-- as a time serious of (property,transaction) pairs, with the most important 
-- attributes (except or parties) slotted in.  Will still contain a small
-- number of "junk" rows with bad BBLS and or null transactions
drop view if exists t1.acris_history cascade; 
create view t1.acris_history as
select 
   a.bbl, a.docid, a.easement, a.partial, a.rights_air, a.rights_sub, a.proptype, a.unit,
   b.doctag, b.doctype, b.amount, b.percentage, b.date_filed, b.date_modified,
   b.docid is not null as in_master
from push.acris_legal as a 
left join push.acris_master as b on a.docid = b.docid;

-- 
-- A view of our history table, minus the "junk" rows above, and with a somewhat
-- tidier set of columns.
-- 
-- Note that the "is_regular_bbl" criterion excludes both invalid/degenerate BBLs
-- as well as marginal ones like 2039379999, 4999990001 etc.  Which most likely are 
-- used by ACRIS as "buckets" to hold deprecated transactions (as in, "we aren't sure
-- about this BBL or transaction set, so let's put it to the side for now.")  
-- 
-- In any case none of these marginal BBLs appear in PAD (as of June 2017), so most 
-- likely aren't meainingful (and would never show up in property searches anyway), 
-- so we exclude them here.  
--
-- About 2000+ rows are affected -- by the "in_master" and "is_regular_bbl" criteria 
-- taken together.
--
create view t1.acris_history_tidy as
select
    bbl, docid, 
    partial::text ||'-'|| 
        easement::integer::text ||'-'|| 
        rights_air::integer::text ||'-'|| 
        rights_sub::integer::text as flags,
    proptype,  unit, doctag, doctype, amount, percentage, date_filed, date_modified
from t1.acris_history where in_master and is_regular_bbl(bbl);

drop view if exists t1.acris_xref cascade; 
create view t1.acris_xref as
select 
  a.bbl,
  coalesce(a.docid,b.docid) as docid,
  a.docid as docid_a,
  b.docid as docid_b
from push.acris_legal as a
full outer join push.acris_master as b on a.docid = b.docid;

commit;

