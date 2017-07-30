--
-- Scrubbing views / tables for acris.legal 
--

begin;

drop schema if exists p0 cascade;
create schema p0;

-- Our preliminary scrubbing table on ACRIS legal: omits some 359k rows which either
-- have no DocID, and/or have irregular BBLs -- both of which conditions presumably  
-- imply the rows are deprecated (or otherwise flagged as erroneous), and in any case
-- would never show up in joins (and hence searches) on legitimate BBLs anyway.
--
-- But still has a significant number of dups (76056 rows across 25325 bbl-docid pairs),
-- which are addressed in the subsequent counting + aggregating views.
--
-- 18,101,346 rows (July 2017)
-- 
create table p0.acris_legal as
select a.* 
from       push.acris_legal  as a
inner join push.acris_master as b on a.docid = b.docid 
where is_regular_bbl(bbl);
create index on p0.acris_legal(bbl);
create index on p0.acris_legal(docid);
create index on p0.acris_legal(docid,bbl);

-- A preliminary version of our history view.
-- Will contain a small proportion of dups (on bbl-docid), but for most searches
-- should give an accurate representation of what's going on for a given property 
-- and/or transaction.
create view p0.acris_history as
select 
   a.bbl, a.docid, a.flags, a.proptype, a.unit, b.doctag, b.doctype, b.docfam,
   b.amount, b.percent, b.docdate, b.filedate 
from p0.acris_legal as a 
left join push.acris_master as b on a.docid = b.docid;

--
-- Our magical de-duping table, with (bbl,docid) as a primary key.  
-- The basic idea is that for rows for which a given attribute has no variance,
-- the "min" and "max" values will be the same (unique) value, so we can just
-- slot these back in - as can be done for the vast majority of cases.
--
-- But in the minority of casese (some 4k+ rows across flags, proptype, + unit),
-- we simply slot in NULL (when selecting off this table) as a way of saying
-- "can't disambiguate".
-- 
-- 18,050,615 rows (July 2017).
-- Feeds into p1.acris_legal, which performs the selection described above.
create table p0.acris_legal_count as
select
    bbl, docid,
    count(distinct flags) as flags,
    count(distinct proptype) as proptype,
    count(distinct unit) as unit,
    count(distinct(street_number,street_name)) as address,
    count(*) as total,
    -- As above, the 'min' and 'max' flags will almost always be identical,
    -- corresponding to 'flags' and 'proptype' (above) = 1, except for about 
    -- 1700 problematic rows that we can't do much about at this stage. 
    -- So in our select from this table, we set the multiply occuring cases 
    -- to null (meaning "can't disambiguate").
    min(flags) as minflags,
    max(flags) as maxflags,
    min(proptype) as minprop,
    max(proptype) as maxprop,
    -- In the vast majority of rows, save about 2300 exceptional cases, there is
    -- at most one non-null "unit" value for a given bbl-docid pair.  The outliers
    -- seem to mostly occur in certain batches of multi-unit coop sales which were
    -- all stuck under a single transaction id for some reason.  
    --
    -- In such cases, the "firstunit" will essentially be random.  But we have the 
    -- the "unit" value (appearing above, which really meanys unit count) to advise 
    -- us on whether to accept it or not, upstream.
    first(unit) as firstunit,
    -- Most of the variance occurs on address, which we don't really care about at 
    -- this stage - and even if we did, we'd have to go back to the non-aggregated table 
    -- to get the full story, anyway.. These are just passed along as a convenience to 
    -- tell us what the "approximate" address for the affected property proabbly is,
    -- for internal troubleshooting.
    first(street_number) as street_number,
    first(street_name) as street_name
from p0.acris_legal group by bbl, docid;
create index on p0.acris_legal_count(bbl);
create index on p0.acris_legal_count(docid);
create index on p0.acris_legal_count(docid,bbl);

-- Our final de-duping step, as described in the statement above, which
-- gets passed directly into the hard table 'p1.acris_legal'.
create view p0.acris_legal_clean as
select
    bbl, docid,
    case when flags = 1 then minflags else null end as flags,
    case when proptype = 1 then minprop else null end as proptype,
    case when unit <= 1 then firstunit else null end as unit,
    unit as ucount,
    total
from p0.acris_legal_count;


--
-- Analytic Views
--

--
-- These next two views provide (when sorted on bbl-docid) groupings of rows which 
-- have variance on proptype and/or flags.  Basically these rows are just "bad news", 
-- because it would be either prohibitively difficult (for the proptype) or essentially  
-- impossible (for the flags) to disambiguated them.
--
-- 2225 rows / 941 composite keys 
create view p0.legal_multi_proptype as
select b.*
from p0.acris_legal_count as a 
left join p0.acris_legal  as b on (a.bbl,a.docid) = (b.bbl,b.docid)
where a.total > 1 and a.proptype > 1 and a.unit <= 1;

-- 964 rows / 375 composite keys
create view p0.legal_multi_flags as
select b.*
from p0.acris_legal_count as a 
left join p0.acris_legal  as b on (a.bbl,a.docid) = (b.bbl,b.docid)
where a.total > 1 and a.flags > 1 and a.unit <= 1;


--
-- Sifting views - Declarations 
--

create table p0.declare_bbl as
select bbl, doctype, count(distinct docid) as docid, count(*) as total
from p0.acris_history where docfam = 5
group by bbl, doctype;
create index on p0.declare_bbl(bbl);

create table p0.declare_docid as
select 
    docid, doctype, 
    min(bbl) as minbbl,
    max(bbl) as maxbbl,
    count(distinct bbl) as total,
    count(distinct bbl2block(bbl)) as qblock 
from p0.acris_history where docfam = 5
group by docid, doctype;
create index on p0.declare_docid(docid);

--
-- Analytic views - Coops
--

create view p0.acris_coop_count as
select bbl, count(distinct docid) as docid, count(*) as total
from p0.acris_history where proptype in ('CP','SP','MP','SA') group by bbl;

create table p0.acris_coop_proptype as
select bbl, proptype, count(distinct docid) as docid, count(*) as total
from p0.acris_history where proptype in ('CP','SP','MP','SA') 
group by bbl, proptype;
create index on p0.acris_coop_proptype(bbl);

-- 
-- For every BBL with at least one CP/SP record, tells us whether the property 
-- appears to be residential ('resi'), commercial ('comm'), or perhaps both.
--
-- Note that not every coop BBL will necessarily appear in this view; it's possible 
-- for a BBL to have solely MP/SA records.
--
create view p0.acris_coop_type as
select
    coalesce(a.bbl,b.bbl) as bbl,
    a.bbl is not null as is_resi,
    b.bbl is not null as is_comm
from
(select bbl from p0.acris_coop_proptype where proptype = 'SP') as a 
full outer join
(select bbl from p0.acris_coop_proptype where proptype = 'CP') as b on a.bbl = b.bbl;

-- A unified view of what we know so far about coop-ish BBLs in ACRIS.
create table p0.acris_coop as
select a.*, b.is_resi, b.is_comm
from p0.acris_coop_count as a  
left join p0.acris_coop_type as b on a.bbl = b.bbl;
create index on p0.acris_coop(bbl);


commit;

/*
create table t2.acris_legal_count as
select 
    docid, bbl, unit, 
    count(*) as total,
    count(distinct (easement,partial,rights_air,rights_sub)) as flags,
    count(distinct (street_number,street_name)) as address,
    count(distinct proptype) as proptype
from push.acris_legal group by docid, bbl, unit;
create index on t2.acris_legal_count(docid);
create index on t2.acris_legal_count(bbl);
create index on t2.acris_legal_count(bbl,unit);
create index on t2.acris_legal_count(docid,bbl,unit);

drop view if exists t2.acris_legal_xref1 cascade; 
create view t2.acris_legal_xref1 as
select 
    a.*, b.doctype, 
    a.bbl, a.unit, a.docid, a.total, b.doctype
from t2.acris_legal_count   as a
left join push.acris_master as b on a.docid = b.docid
where a.total > 1;
*/


