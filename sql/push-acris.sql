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

commit;

