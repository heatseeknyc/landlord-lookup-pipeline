
begin;

-- All columns cast in the obvious way. 
drop view if exists core.pad_adr cascade; 
create view core.pad_adr as
select
    soft_bbl(boro,block,lot) as bbl,
    soft_int(bin) as bin,
    normfw(lhnd) as lhnd, 
    normfw(lhns) as lhns, 
    normfw(lcontpar) as lcontpar, 
    normfw(lsos) as lsos,
    normfw(hhnd) as hhnd, 
    normfw(hhns) as hhns, 
    normfw(hcontpar) as hcontpar, 
    normfw(hsos) as hsos,
    soft_int(scboro)::smallint as scboro, 
    normfw(sc5) as sc5,
    normfw(sclgc) as sclgc,
    normfw(stname) as stname,
    normfw(addrtype) as addrtype, 
    normfw(realb7sc) as realb7sc, 
    normfw(validlgcs) as validlgcs, 
    normfw(dapsflag) as dapsflag,
    normfw(naubflag) as naubflag, 
    soft_int(parity)::smallint as parity,
    normfw(b10sc) as b10sc,
    soft_int(segid) as segid,
    soft_int(zipcode) as zipcode, 
    soft_int(physical_id) as physical_id 
from flat.pad_adr;

-- Creates BBLs + casts other columns as appropriate. 
-- Drops the 3 SCC columns, as these don't seem to have any external meaning. 
drop view if exists core.pad_bbl cascade; 
create view core.pad_bbl as
select
    soft_bbl(loboro,loblock,lolot) as lo_bbl,
    soft_bbl(hiboro,hiblock,hilot) as hi_bbl,
    soft_bbl(boro,block,lot) as bbl,
    soft_bbl(billboro,billblock,billlot) as bill_bbl,
    normfw(condoflag) as condoflag,
    soft_int(condonum) as condonum,
    soft_int(coopnum) as coopnum,
    soft_int(numbf) as numbf,
    normfw(numaddr) as numaddr,
    normfw(vacant) as vacant,
    normfw(interior) as interior
from flat.pad_bbl;

commit;

