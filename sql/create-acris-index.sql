
begin;

create index on push.acris_master(docid);
create index on push.acris_master(docid,doctag);
create index on push.acris_master(docid,doctype);
-- create index on push.acris_master(crfn);
-- create index on push.acris_master(docid,crfn);

create index on push.acris_legal(docid);
create index on push.acris_legal(bbl);
create index on push.acris_legal(docid,bbl);

create index on push.acris_party(docid);
create index on push.acris_party(docid,party_type);

commit;

