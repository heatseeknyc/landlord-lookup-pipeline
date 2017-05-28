
begin;

drop table if exists flat.acris_master cascade; 
drop table if exists flat.acris_legals cascade; 
drop table if exists flat.acris_parties cascade; 
drop table if exists flat.acris_master_codes cascade; 

create table flat.acris_master_codes (
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
    date_document date, 
    amount numeric not null,
    date_filed date not null, 
    date_modified date not null, 
    reel_year smallint not null,
    reel_number integer not null, 
    reel_page integer not null, 
    percentage numeric not null,
    date_valid_thru date not null
);

create table flat.acris_legals (
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

create table flat.acris_parties (
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

begin;
