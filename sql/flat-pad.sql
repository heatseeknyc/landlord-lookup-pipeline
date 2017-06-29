

--
-- Flat schema for the ADR and BBL fixed-width tables in the 
-- Bytes of the Big Apple Property Address Directory (PAD), v17b.
--
-- Character widths in both tables are aligned exactly to the data dictionary 
-- for that release (except the 'physical_id' column, which wasn't present
-- in the dictionary for some reason).
--

begin;

drop table if exists flat.pad_adr cascade;
create table flat.pad_adr (
    boro char(1) 
    block char(5) 
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

drop table if exists flat.pad_bbl cascade;
create table flat.pad_bbl (
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

commit;


/*

"boro","block","lot","bin",
"lhnd","lhns","lcontpar","lsos",
"hhnd","hhns","hcontpar","hsos",
"scboro","sc5","sclgc","stname","addrtype","realb7sc","validlgcs","dapsflag",
"naubflag","parity","b10sc","segid","zipcode","physical_id"

"1","00001","0010","1089249",
 1234567890ab
"            ","           "," ","L",
"            ","           "," ","L",                    12345678   12345678
"1","00074","01","HUGH CAREY TNNL VENTILATOR BLDG ","N","        ","01      "," ",
" ","0","10007401010","0132761","10004","       "
         1234567890A                     1234567

*/

/*
  "loboro","loblock","lolot","lobblscc",
  "hiboro","hiblock","hilot","hibblscc",
  "boro","block","lot","bblscc",
  "billboro","billblock","billlot","billbblscc",
  "condoflag","condonum","coopnum","numbf","numaddr","vacant","interior"

  "1","00001","0010","7",
  "1","00001","0010","7",
  "1","00001","0010","7"," ",
  "     ","    "," "," ",
  "    ","    ","27","0461"," ", " "
   1234   1234
*/


