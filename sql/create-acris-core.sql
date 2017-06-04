--
-- These views mostly pass the columns from the flat tables as-is, with the 
-- following qualifications:
--
--   - 'rectype' is skipped (as it takes a constant value on all tables) 
--   - in acris_party, degenerate 'state' values are mapped to NULL  (currently affecting 19 rows)
--   - changes in column order, here and there.
--

begin;

drop view if exists core.acris_control cascade; 
drop view if exists core.acris_master cascade; 
drop view if exists core.acris_legal cascade; 
drop view if exists core.acris_party cascade; 
drop view if exists core.acris_master_docid_tidy cascade; 
drop materialized view if exists core.acris_master_docid_count cascade; 
drop view if exists core.acris_master_clean cascade; 

create view core.acris_control as 
select
  doctype, description, classcode, ptype1, ptype2, ptype3,
  case
    when classcode = 'UCC AND FEDERAL LIENS' then 'LIEN'
    when classcode = 'DEEDS AND OTHER CONVEYANCES' then 'DEED' 
    when classcode = 'OTHER DOCUMENTS' then 'OTHR'
    when classcode = 'MORTGAGES & INSTRUMENTS' then 'MORT'
    else NULL
  end as doctag
from flat.acris_control;

create view core.acris_master as 
select 
  a.docid, a.crfn, a.boro, b.doctag, a.doctype, a.amount, a.percentage, a.reel_year, a.reel_number, a.reel_page,  
  a.date_document, a.date_filed, a.date_modified, a.date_valid_thru
from flat.acris_master            as a 
left join core.acris_control as b on a.doctype = b.doctype; 

create view core.acris_legal as 
select 
  docid, public.make_bbl(boro,block,lot) as bbl, easement, partial, rights_air, rights_sub, proptype,
  street_name, street_number, unit, date_valid_thru 
from flat.acris_legal;

create view core.acris_party as 
select 
  docid, party_type, name, address1, address2, country, city, 
  case when length(state) = 2 then state else null end as state,
  postal, date_valid_thru 
from flat.acris_party;

-- This MV is costly time-wise (90 sec or so) but tiny space-wise (currently 749 rows)
-- and should make the de-duping select in the next view go much faster.
create materialized view core.acris_master_docid_count as 
select docid,count(*) as kount from core.acris_master group by docid having count(*) > 1;
create index on core.acris_master_docid_count(docid);

create view core.acris_master_clean as
select a.* 
from      core.acris_master             as a
left join core.acris_master_docid_count as b on a.docid = b.docid
where b.docid is null;

-- A tidier view of the master table, restricted to essential columns 
create view core.acris_master_tidy as 
select docid,doctag,doctype,amount,percentage,date_filed,date_modified from core.acris_master_clean;


commit;

