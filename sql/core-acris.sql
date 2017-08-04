--
-- These views mostly pass the columns from the flat tables as-is, with the 
-- following qualifications:
--
--   - 'rectype' is skipped (as it takes a constant value on all tables) 
--   - in acris_party, degenerate 'state' values are mapped to NULL  (currently affecting 19 rows)
--   - changes in column order, here and there.
--

begin;


drop materialized view if exists core.acris_refdata_control cascade;
create materialized view core.acris_refdata_control as
select
  doctype, description, classcode, ptype1, ptype2, ptype3,
  case
    when classcode = 'UCC AND FEDERAL LIENS' then 'LIEN'
    when classcode = 'DEEDS AND OTHER CONVEYANCES' then 'DEED' 
    when classcode = 'OTHER DOCUMENTS' then 'OTHR'
    when classcode = 'MORTGAGES & INSTRUMENTS' then 'MORT'
    else NULL
  end as doctag
from flat.acris_refdata_control;
create index on core.acris_refdata_control(doctype);

-- A nearly trivial push, just to have it in the core schema (and indexed).
drop table if exists core.acris_refdata_docfam cascade;
create table view core.acris_refdata_docfam as
select * from flat.acris_refdata_docfam;
create index on core.acris_refdata_docfam(doctype);

drop view if exists core.acris_master cascade;
create view core.acris_master as
select
  docid, crfn, boro, doctype, amount, percentage, reel_year, reel_number, reel_page,
  case when
      public.is_valid_mmddyyyy(date_document) then date_document::date else NULL
  end as date_document, 
  date_filed, date_modified, date_valid_thru
from flat.acris_master;  --             as a;
-- left join core.acris_refdata_control as b on doctype = b.doctype; 

-- An "information-preserving" mapping of the original flatfile columns as follows: 
--  - Merges (boro, block, lot) into an integer bbl, 
--  - Merges 4 "easement/rights" booleans into a single string (char(7)) 
-- passes all other columns as-is
-- except for 'rectype' which is always 'L' in the flat file.
drop view if exists core.acris_legal cascade; 
create view core.acris_legal as 
select 
  docid, public.make_bbl(boro,block,lot) as bbl, unit, proptype, 
  mkflags_acris(easement, partial, rights_air, rights_sub) as flags,
  street_number, street_name, 
  date_valid_thru 
from flat.acris_legal;

drop view if exists core.acris_party cascade; 
create view core.acris_party as 
select 
  docid, party_type, name, address1, address2, country, city, 
  case when length(state) = 2 then state else null end as state,
  postal, date_valid_thru 
from flat.acris_party;

commit;

