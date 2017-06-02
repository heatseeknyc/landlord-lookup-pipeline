--
-- Hardened tables for intermediate ACRIS datasets.
--

begin;

drop table if exists push.acris_master cascade;
drop table if exists push.acris_legals cascade;
drop table if exists push.acris_parties cascade;

create table push.acris_master as
select * from core.master_tidy where doctag = 'DEED';

create table push.acris_legals as
select * from core.acris_legals;

create table push.acris_parties as
select * from core.acris_parties;

create index on push.acris_master(docid);
create index on push.acris_master(docid,doctag);
create index on push.acris_master(docid,doctype);
-- create index on push.acris_master(crfn);
-- create index on push.acris_master(docid,crfn);

create index on push.acris_legals(docid);
create index on push.acris_legals(bbl);
create index on push.acris_legals(docid,bbl);

create index on push.acris_parties(docid);
create index on push.acris_parties(docid,party_type);

commit;

