

--
-- Flat schema for the ADR and BBL fixed-width tables in the 
-- Bytes of the Big Apple Property Address Directory (PAD), v17b.
--
-- Character widths in both tables are aligned exactly to the data dictionary 
-- for that release (except the 'physical_id' column, which wasn't present
-- in the dictionary for some reason).
--

begin;

drop table if exists flat.dcp_pad_adr cascade;
create table flat.dcp_pad_adr (
    boro char(1),
    block char(5), 
    lot char(4),
    bin char(7),
    lhnd char(12), 
    lhns char(11), 
    lcontpar char(1), 
    lsos char(1),
    hhnd char(12), 
    hhns char(12), 
    hcontpar char(1), 
    hsos char(1),
    scboro char(1),
    sc5 char(5),
    sclgc char(2),
    stname char(32),
    addrtype char(1), 
    realb7sc char(8), 
    validlgcs char(8), 
    dapsflag char(1),
    naubflag char(1), 
    parity char(1), 
    b10sc char(11), 
    segid char(7), 
    zipcode char(5), 
    physical_id char(7)
);

drop table if exists flat.dcp_pad_bbl cascade;
create table flat.dcp_pad_bbl (
    loboro char(1),   
    loblock char(5),   
    lolot char(4),   
    lobblscc char(1),
    hiboro char(1),   
    hiblock char(5),
    hilot char(4),
    hibblscc char(1),
    boro char(1),
    block char(5),
    lot char(4),
    bblscc char(1),
    billboro char(1), 
    billblock char(5), 
    billlot char(4), 
    billbblscc char(1),
    condoflag char(1), 
    condonum char(4), 
    coopnum char(4),
    numbf char(2), 
    numaddr char(4), 
    vacant char(1), 
    interior char(1)
);

-- Finally - our magical condo map.
-- Constraints are provided mainly for descriptive purposes (since we generate 
-- the data ourselves, we don't expect it to be out of whack).
drop table if exists flat.dcp_condo_map cascade;
create table flat.dcp_condo_map (
    bank bigint CHECK (is_condo_bbl(bank)),
    unit bigint CHECK (is_regular_bbl(unit)),
    UNIQUE(bank,unit),
    UNIQUE(unit)
);

/* 
Borough Code,Tax Block,Tax Lot,Zoning District 1,Zoning District 2,Zoning District 3,Zoning District 4,Commercial Overlay 1,Commercial Overlay 2,Special District 1,Special District 2,Special District 3,Limited Height District,Zoning Map Number,Zoning Map Code
1,1,10,R3-2,,,,,,GI,,,,16A,Y
1,1,101,R3-2,,,,,,,,,,16A,Y
1,1,201,R3-2,,,,,,,,,,12B, */
create table flat.dcp_zoning (
    BoroughCode smallint not null,
    TaxBlock integer not null,
    TaxLot smallint not null,
    ZoningDistrict1 text,
    ZoningDistrict2 text,
    ZoningDistrict3 text,
    ZoningDistrict4 text,
    CommercialOverlay1 text,
    CommercialOverlay2 text,
    SpecialDistrict1 text,
    SpecialDistrict2 text,
    SpecialDistrict3 text,
    LimitedHeightDistrict text,
    ZoningMapNumber text,
    ZoningMapCode text
);

commit;

