--
-- Hardened tables for intermediate ACRIS datasets.
--

begin;

--
-- First, a 3-stage de-duping step for the 'master' table.
-- Ths involves creating a hard table which we'll later drop.
--

-- This table is costly time-wise (90 sec or so) but tiny space-wise (currently 749 rows)
-- and should make the de-duping select in the next view go much faster.
drop table if exists push.acris_master_docid_count cascade; 
create table push.acris_master_docid_count as  
select docid, count(*) as total from core.acris_master group by docid having count(*) > 1;
create index on push.acris_master_docid_count(docid);

-- A deduping view based on presence (or lack thereof) in the above table.
drop view if exists push.acris_master_clean cascade; 
create view push.acris_master_clean as
select a.* 
from      core.acris_master             as a
left join push.acris_master_docid_count as b on a.docid = b.docid
where b.docid is null;

-- A tidier view of the master table, restricted to essential columns 
drop view if exists push.acris_master_tidy cascade; 
create view push.acris_master_tidy as  
select 
    docid, doctag, doctype, amount, percentage, 
    date_filed as filedate, 
    date_document as docdate
from push.acris_master_clean;

--
-- Now we can select into our tables of direct interest. 
--

drop table if exists push.acris_master cascade;
create table push.acris_master as
select * from push.acris_master_tidy;
create index on push.acris_master(docid);
create index on push.acris_master(docid,doctag);
create index on push.acris_master(docid,doctype);

drop table if exists push.acris_deeds cascade;
create table push.acris_deeds as
select * from push.acris_master_tidy where doctag = 'DEED';
create index on push.acris_deeds(docid);
create index on push.acris_deeds(docid,doctag);
create index on push.acris_deeds(docid,doctype);

drop table if exists push.acris_legal cascade;
create table push.acris_legal as
select * from core.acris_legal;
create index on push.acris_legal(bbl);
create index on push.acris_legal(docid);
create index on push.acris_legal(docid,bbl);

drop table if exists push.acris_legal_count cascade;
create table push.acris_legal_count as
select bbl, count(*) as total, count(distinct proptype) as proptype
from push.acris_legal group by bbl;
create index on push.acris_legal_count(bbl);

drop table if exists push.acris_party cascade;
create table push.acris_party as
select * from core.acris_party;
create index on push.acris_party(docid);
create index on push.acris_party(docid,party_type);

-- A crucial table telling us the number of parties of a given transaction and party_type.
-- 27,684,101 rows - 5 min  
drop table if exists push.acris_party_count cascade;
create table push.acris_party_count as
select docid, party_type, count(*) as total
from push.acris_party group by docid, party_type;
create index on push.acris_party_count(docid);
create index on push.acris_party_count(docid,party_type);

/*
create table push.acris_party_single as
select
    a.docid, a.party_type,
    name, address1, address2, country, city, state, postal
from push.acris_party_count as a
left join push.acris_party  as b on (a.docid,a.party_type) = (b.docid,b.party_type)
where a.total = 1;
create index on push.acris_party_single(docid,party_type);
*/

-- A nifty view showing name+address for single-party transactions only,
-- where these are known.  Note that it gets a crucial lift from the index 
-- on 'acris_party_count' - if that index drops, then select times on this
-- view will grind form to a hald.
create view push.acris_party_single as
select
    a.docid, a.party_type,
    name, address1, address2, country, city, state, postal
from push.acris_party_count as a
left join push.acris_party  as b on (a.docid,a.party_type) = (b.docid,b.party_type)
where a.total = 1;


--
-- Purge the counting table we no longer need. 
--
drop table if exists push.acris_master_docid_count cascade; 

commit;

