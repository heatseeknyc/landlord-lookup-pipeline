
begin;

drop table if exists flat.acris_control cascade; 
drop table if exists flat.acris_master cascade; 
drop table if exists flat.acris_legal cascade; 
drop table if exists flat.acris_party cascade; 

create table flat.acris_refdata_control (
    rectype char(1) not null,
    doctype text primary key, 
    description text not null,
    classcode text not null,
    ptype1 text,
    ptype2 text,
    ptype3 text
);

create table flat.acris_master (
    docid char(16) not null,
    rectype char(1) not null,
    crfn char(13),
    boro smallint not null,
    doctype text not null,
    date_document char(10), -- sometimes has corrupted year values, e.g. '05/29/0200'
    amount numeric not null,
    date_filed date not null, 
    date_modified date not null, 
    reel_year smallint not null,
    reel_number integer not null, 
    reel_page integer not null, 
    percentage numeric not null,
    date_valid_thru date not null
);

create table flat.acris_legal (
    docid char(16) not null,
    rectype char(1) not null,
    boro smallint not null,
    block integer not null, 
    lot smallint not null,
    easement boolean not null, 
    partial char(1) not null,
    rights_air boolean not null,
    rights_sub boolean not null,
    proptype char(2) not null,
    street_number text,
    street_name text,
    unit text,
    date_valid_thru date not null
);

create table flat.acris_party (
    docid char(16) not null,
    rectype char(1) not null,
    party_type smallint not null,
    name text,
    address1 text,
    address2 text,
    country char(2), 
    city text,
    state char(2),
    postal text,
    date_valid_thru date not null
);

commit;


