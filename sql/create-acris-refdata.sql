
begin;

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

commit;

