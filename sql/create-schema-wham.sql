begin;

drop schema if exists wham cascade;
create schema wham; 

drop table if exists wham.dhcr;
create table wham.dhcr ( 
    bbl bigint PRIMARY KEY,
    count integer not null,
    tags text
);

commit;

