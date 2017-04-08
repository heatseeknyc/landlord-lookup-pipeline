--
-- A new side schema for provisional designs of new tables in the 'flat' schema. 
--  

begin;

drop schema if exists temp cascade;
create schema temp; 

create table temp.taxbills (
    bbl bigint CHECK (bbl >= 1000000000 and bbl < 6000000000),
    year smallint CHECK (year > 0),
    quarter smallint CHECK (quarter >= 1 and quarter <= 4),
    htype smallint CHECK (htype >= 1 and htype <= 2),
    taxclass varchar(2) null,
    unitcount smallint null,
    estimated bigint null,
    amount float(2),
    UNIQUE (bbl, year, quarter)
);

commit;

