
begin;

create table flat.stable_taxbill (
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

create table flat.stable_dhcr2015_grouped ( 
    bbl bigint primary key,
    count integer not null,
    dwell char(1),
    has_421a boolean not null,
    has_j51 boolean not null,
    special text
);

-- Deprecated
create table flat.stable_joined (
    bbl bigint not null CHECK (bbl >= 1000000000 and bbl < 6000000000),
    year smallint not null, 
    unitcount integer,
    estimate boolean not null,
    in_dhcr boolean not null,
    abatements text,
    UNIQUE (bbl, year)
);

-- JK's 'joined-crosstab.csv', as-is.  Note that we'll only be needing the 
-- first 6 columns (and so won't sweat the column types in the rest).
create table flat.stable_joined_nocrosstab (
    ucbbl bigint not null CHECK (ucbbl >= 1000000000 and ucbbl < 6000000000),
    year date,
    unitcount integer,
    estimate char(1), 
    indhcr char(1),
    abatements text,
    cd text,
    ct2010 text,
    cb2010 text,
    council text,
    zipcode text,
    address text,
    ownername text,
    numbldgs integer,
    numfloors text,
    unitsres integer,
    unitstotal integer,
    yearbuilt integer,
    condono integer,
    lon float,
    lat float,
    UNIQUE (ucbbl, year)
);

commit;

