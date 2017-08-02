--
-- Some intermediate aggregations of ACRIS data.
-- Of special note are the tables 'acris_history' and 'party_history',
-- which are not used in the gateway (currently) but are useful for doing
-- searches and analytics.
--

begin;

drop schema if exists p1 cascade;
create schema p1;

-- A direct pull of our de-duping table.
-- Will be unique on (bbl,docid), and almost all of the key attributes
-- (proptype, flags, unit) will be non-null and "correct" for that 
-- composite key.  
--
-- However, around 1700 of these will have either 'proptype' and/or 'flags' 
-- set to NULL, meaning "can't disambiguate".  And another 2300 will have 
-- 'unit' set to null, also meaning "can't disambiguate".  (But unlke the 
-- former 2 columns, 'unit' will frequently be null anyway, even though there
-- was no disambiguation issue).
--
-- Again, the former batch are apparently failed updates (and there's really 
-- isn't anything we can do to try to disambiguate them).  And the cases where 
-- 'unit' is set to NULL probably indicate batches of multi-unit coop sales.
-- These we could perhaps address, but for now we'll simply punt.
--
-- 18,050,615
create table p1.acris_legal as select * from p0.acris_legal_clean;
create index on p1.acris_legal(bbl);
create index on p1.acris_legal(docid);
create index on p1.acris_legal(bbl,docid);

--
-- Our new history table, reasonably de-duped.
--
-- Now unique on (docid,bbl); 'proptype' and 'flags' will be non-null for all but 
-- a small number of rows (around 1700).  The 'ucount' column is included to advise
-- as to the 'unit' column (see notes above).
--
-- BTW note that while every row will have a 'filedate', for some 60% of these rows, 
-- the 'docdate' will be NULL.  So we coalesce them onto our "effective date" column. 
--
-- 18,050,615 rows
create table p1.acris_history as
select 
   a.bbl, a.docid, a.flags, a.proptype, a.unit, b.doctag, b.doctype, b.docfam,
   b.amount, b.percent, b.docdate, b.filedate,
   coalesce(b.docdate,b.filedate) as effdate,
   a.ucount 
from      p1.acris_legal    as a 
left join push.acris_master as b on a.docid = b.docid;
create index on p1.acris_history(bbl);
create index on p1.acris_history(docid);
create index on p1.acris_history(docid,bbl);

create view p1.acris_history_tidy as
select
   bbl, docid, flags, proptype, unit, doctag, doctype, docfam, amount, percent, docdate, filedate
from p1.acris_history;

-- For every BBL in our (scrubbed) history, tells us:
-- row count, docid count, min/max effective dates.
-- 1,154,260 rows
create table p1.acris_history_count as 
select 
    bbl, 
    count(*) as total, 
    count(distinct docid) as docid,
    min(effdate) as mindate,
    max(effdate) as maxdate
from p1.acris_history group by bbl;
create index on p1.acris_history_count(bbl);


-- Like the above, but tells us min/max/total within a given doctype family. 
-- size = 2-3x the above
create table p1.acris_history_grouped as
select 
    bbl, docfam, 
    min(effdate) as mindate,
    max(effdate) as maxdate,
    count(*) as total
from p1.acris_history where docfam is not null 
group by bbl, docfam;
create index on p1.acris_history_grouped(bbl);
create index on p1.acris_history_grouped(docfam);
create index on p1.acris_history_grouped(bbl,docfam);

-- A view of the ACRIS parties the way they were "meant" to be viewed, 
-- that is, as a time series adjoined to history, with all party fields 
-- slotted in.  (We won't usually access this view directly, so we call
-- it the "wide" view).
create view p1.party_history_wide as
select a.bbl, a.doctag, a.doctype, a.docfam, a.docdate, a.filedate, a.effdate, b.* 
from      p1.acris_history as a
left join push.acris_party as b on a.docid = b.docid;

-- A somewhat tidier form the "party history" view. 
create view p1.party_history as
select 
    bbl, docid, doctag, doctype, docfam, effdate, party_type as party,
    substr(name,1,35) as name, substr(address1,1,35) as address1
from p1.party_history_wide;




--
-- Sifting views - Declarations 
--

--
-- A pair of counting tables on DocID and BBL, respectively, for transactions
-- which represent some form of declaration (zoning or condo).  Note that these
-- form the respective vertex sets of our bipartite graph of related transactions.
--

-- 349,654 rows
create table p1.declare_bbl as
select bbl, doctype, count(distinct docid) as docid, count(*) as total
from p1.acris_history where docfam = 5
group by bbl, doctype;
create index on p1.declare_bbl(bbl);

-- 24,200 rows
create table p1.declare_docid as
select 
    docid, doctype, 
    min(bbl) as minbbl,
    max(bbl) as maxbbl,
    count(distinct bbl) as total,
    count(distinct bbl2block(bbl)) as qblock 
from p1.acris_history where docfam = 5
group by docid, doctype;
create index on p1.declare_docid(docid);

--
-- Analytic views - Coops
-- Row counts for July 2017

-- 13386 rows
-- Note that 'docid' and 'total' will be identical in this table (and downstream)
-- due to our de-deping process, but that's OK (and these views help demonstrate that).
create view p1.acris_coop_count as
select bbl, count(distinct docid) as docid, count(*) as total
from p1.acris_history where proptype in ('CP','SP','MP','SA') group by bbl;

-- Approx 2-3x the above
create table p1.acris_coop_proptype as
select bbl, proptype, count(distinct docid) as docid, count(*) as total
from p1.acris_history where proptype in ('CP','SP','MP','SA') 
group by bbl, proptype;
create index on p1.acris_coop_proptype(bbl);

-- 
-- For every BBL with at least one CP/SP record, tells us whether the property 
-- appears to be residential ('resi'), commercial ('comm'), or perhaps both.
--
-- Note that not every coop BBL will necessarily appear in this view; it's possible 
-- for a BBL to have solely MP/SA records.
--
-- 13063 rows
create view p1.acris_coop_type as
select
    coalesce(a.bbl,b.bbl) as bbl,
    a.bbl is not null as is_resi,
    b.bbl is not null as is_comm
from
(select bbl from p1.acris_coop_proptype where proptype = 'SP') as a 
full outer join
(select bbl from p1.acris_coop_proptype where proptype = 'CP') as b on a.bbl = b.bbl;

--
-- A unified view of what we know so far about coop-ish BBLs in ACRIS.
-- As in the upstream views, the 'docid' and 'total' columns will be identical.
--
-- Note that there are some 800+ coops in PAD not present in this table.  Many of them
-- do have ACRIS transactions -- just no SP/CP transfers, for whatever reason.
--
-- 13386 rows, with sum(total) around 250k.
--
create table p1.acris_coop as
select a.*, b.is_resi, b.is_comm
from p1.acris_coop_count as a  
left join p1.acris_coop_type as b on a.bbl = b.bbl;
create index on p1.acris_coop(bbl);

commit;

/*

--
-- Now join them into a 'ledger' table.
-- 1154260 rows
drop table if exists p1.acris_history_profile cascade; 
create table p1.acris_history_profile as 
select 
    a.*, 
    b.date_filed as last_transfer
from p1.acris_history_count   as a
left join p1.last_convey_date as b on a.bbl = b.bbl;
create index on p1.acris_history_profile(bbl);
-- Whereupon we drop the temporary tables.
drop table p1.last_convey_date;
drop table p1.acris_history_count;



create view p1.doctype_count as
select 
    doctag, doctype, count(distinct bbl) as taxlot,
    min(date_filed) as mindate, max(date_filed) as maxdate, 
    count(*) as rowcount 
from p1.acris_history group by doctag, doctype;

create table p1.doctype_survey as
select 
    doctag, a.doctype, b.family as docfam, taxlot, mindate, maxdate, rowcount 
from p1.doctype_count as a
left join core.acris_refdata_docfam as b on a.doctype = b.doctype;
create index on p1.doctype_survey(doctype);
create index on p1.doctype_survey(doctag);
create index on p1.doctype_survey(docfam);

-- A nifty view of BBLs that cross-relate via a shared docid.
-- In essence, the tuples (basebbl,bbl) from the edge list for a big  
-- bipartit graph.  We don't know how big exactly, but queries on this 
-- rowset can blow up very quickly, so be careful.
create view p1.acris_xlegal as
select a.bbl as basebbl, b.*
from      p1.acris_history as a
left join p1.acris_history as b on a.docid = b.docid;

*/

