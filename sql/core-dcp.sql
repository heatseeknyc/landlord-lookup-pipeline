--
-- Columns in both table are cast in the "obvious" way:
-- That is, BBLs created where indicated, and other columns cast to trimmed text 
-- (via 'normfw') or to integers (via 'soft_int'), in both cases defaulting to NULL 
-- where appropriate.
--

begin;

drop view if exists core.dcp_pad_adr cascade; 
create view core.dcp_pad_adr as
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
from flat.dcp_pad_adr;

-- We drop the 4 SCC columns, as these don't seem to have any external meaning. 
drop view if exists core.dcp_pad_bbl cascade; 
create view core.dcp_pad_bbl as
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
from flat.dcp_pad_bbl;

commit;

