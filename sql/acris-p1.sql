--
-- Some intermediate aggregations of ACRIS data.
-- Of special note are the tables 'acris_history' and 'party_history',
-- which are not used in the gateway (currently) but are useful for doing
-- searches and analytics.
--

begin;

drop schema if exists p1 cascade;
create schema p1;

-- 18055244 rows in t min 
drop table if exists p1.acris_history cascade;
create table p1.acris_history as
select a.*, b.family as docfam, public.bbl2qblock(bbl) as qblock 
from t1.acris_history_tidy          as a
left join core.acris_refdata_docfam as b on a.doctype = b.doctype;
create index on p1.acris_history(bbl);
create index on p1.acris_history(docid);

-- 1152338 rows
drop table if exists p1.acris_history_count cascade; 
create table p1.acris_history_count as 
select 
    qblock, bbl, 
    count(*) as total, 
    count(distinct docid) as docid_count, 
    max(date_filed) as mindate,
    max(date_filed) as maxdate
from p1.acris_history group by qblock, bbl;
create index on p1.acris_history_count(bbl);


-- A view of the ACRIS parties the way they were "meant" to be viewed, 
-- that is, as a time series adjoined to history, with all party fields 
-- slotted in.  (We won't usually access this view directly, so we call
-- it the "wide" view).
create view p1.party_history_wide as
select a.bbl, a.doctag, a.doctype, a.docfam, a.date_filed, b.* 
from p1.acris_history      as a
left join push.acris_party as b on a.docid = b.docid;

-- A somewhat tidier form the "party history" view.  Let's make our 
-- default view on this rowset.
create view p1.party_history as
select 
    bbl, docid, doctag, doctype, docfam, date_filed, party_type as party,
    substr(name,1,35) as name, substr(address1,1,35) as address1
from p1.party_history_wide;

create view p1.party_first as
    select docid, party_type, first(name), first(address)
from p1.acris_history      as a
left join push.acris_party as b on a.docid = b.docid;
group by docid, party_type;


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

commit;

