--
-- Hardened tables for intermediate ACRIS datasets.
--

begin;

drop table if exists push.acris_master cascade;
drop table if exists push.acris_deeds cascade;
drop table if exists push.acris_legal cascade;
drop table if exists push.acris_party cascade;

create table push.acris_master as
select * from core.acris_master_tidy;
create index on push.acris_master(docid);
create index on push.acris_master(docid,doctag);
create index on push.acris_master(docid,doctype);

create table push.acris_deeds as
select * from core.acris_master_tidy where doctag = 'DEED';
create index on push.acris_deeds(docid);
create index on push.acris_deeds(docid,doctag);
create index on push.acris_deeds(docid,doctype);

create table push.acris_legal as
select * from core.acris_legal;
create index on push.acris_legal(bbl);
create index on push.acris_legal(docid);
create index on push.acris_legal(docid,bbl);

create table push.acris_party as
select * from core.acris_party;
create index on push.acris_party(docid);
create index on push.acris_party(docid,party_type);

commit;

