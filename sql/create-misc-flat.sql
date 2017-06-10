
begin;

create table flat.misc_liensale (
    bbl bigint CHECK (bbl >= 1000000000 and bbl < 6000000000),
    year integer CHECK (year > 0),
    taxclass integer,
    waterdebt boolean,
    UNIQUE (bbl, year)
);

create table flat.misc_nycha (
    development text,
    managed_by text,
    house text,
    street text,
    zipcode integer,
    block integer,
    lot smallint,
    bin text,
    boroname text,
    boroid smallint
);

commit;

