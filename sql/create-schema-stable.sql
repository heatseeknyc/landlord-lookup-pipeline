
begin;

create table flat.taxbills (
    bbl bigint CHECK (bbl >= 1000000000 and bbl < 6000000000),
    year smallint CHECK (year > 0),
    quarter smallint CHECK (quarter >= 1 and quarter <= 4),
    htype smallint CHECK (htype >= 1 and htype <= 2),
    taxclass varchar(2) null,
    unitcount smallint null,
    estimated bigint null,
    amount float(2),
    has_421a boolean,
    has_j51 boolean,
    UNIQUE (bbl, year, quarter)
);

create table flat.dhcr2015 ( 
    bbl bigint primary key,
    count integer not null,
    dwell char(1),
    has_421a boolean not null,
    has_j51 boolean not null,
    special text
);

create table flat.liensales (
    bbl bigint CHECK (bbl >= 1000000000 and bbl < 6000000000),
    year integer CHECK (year > 0),
    taxclass integer,
    waterdebt boolean,
    UNIQUE (bbl, year)
);

commit;
