--
-- Hardened tables for intermediate ACRIS datasets.
--

begin;

drop table if exists push.acris_master cascade;
drop table if exists push.acris_legal cascade;
drop table if exists push.acris_party cascade;

create table push.acris_master as
select * from core.master_tidy where doctag = 'DEED';

create table push.acris_legal as
select * from core.acris_legal;

create table push.acris_party as
select * from core.acris_party;

commit;

