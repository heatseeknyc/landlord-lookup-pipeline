
begin;

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

