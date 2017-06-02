
begin;

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

