
--
-- Datasets for the NYC Landmarks Preservation Commission 
--

-- BBL,BIN_NUMBER,the_geom,OBJECTID,BoroughID,BLOCK,LOT,LP_NUMBER,LM_NAME,PLUTO_ADDR,DESIG_ADDR,DESIG_DATE,CALEN_DATE,PUBLIC_HEA,LM_TYPE,HIST_DISTR,OTHER_HEAR,BOUNDARIES,MOST_CURRE,STATUS,LAST_ACTIO,STATUS_NOT,COUNT_BLDG,NON_BLDG,VACANT_LOT,SECND_BLDG
-- 1008510001,1016278,POINT (-73.9896512493664 40.74100404032538),57253,MN,851,1,LP-00219,Flatiron Building,171 5 AVENUE,171 5 AVENUE,09/20/1966 12:00:00 AM +0000,,3/8/1966,Individual Landmark,"Yes, Ladies' Mile",,Block & Lot,1,DESIGNATED,DESIGNATED,,1,,0,0

begin;

drop table if exists flat.lpc_indiv cascade;
create table flat.lpc_indiv (
    BBL bigint null, 
    BIN integer not null,
    the_geom text,
    ObjectID integer,
    BoroughID char(2),
    Block integer,
    Lot smallint,
    lp_number text,
    lm_name text,
    pluto_addr text,
    desig_addr text,
    desig_date date,
    calen_date date,
    public_hea text, -- sometimes multiple
    lm_type text,
    hist_distr text,
    other_hear text,
    boundaries text,
    most_curre smallint, -- always 0 or 1 
    status text, -- sometimes misspellt, eg 'NOT DESIGNTAED'
    last_actio text,
    stat_not text,
    count_bldg smallint,
    non_bldg text,
    vacant_lot smallint,
    second_bldg smallint 
);

-- An overlay tables for entity names in the above table that would be hard
-- to disambiguate automatically - so we do it by hand.  
drop table if exists flat.lpc_indiv_name cascade;
create table flat.lpc_indiv_name (
    bbl bigint CHECK (is_valid_bbl(bbl)),
    bin integer CHECK (is_valid_bin(bin)),
    name text not null,
    UNIQUE (bbl,bin)
);

commit;

