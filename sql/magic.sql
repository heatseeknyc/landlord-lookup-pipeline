select a.bbl,a.bldg_count,a.bldg_class,a.condo_number,a.units,a.stable,c.docid,c.doctag,c.doctype,c.date_filed,c.date_modified
from kool.endangered_taxlots as a
left join push.acris_legals  as b on a.bbl = b.bbl
left join temp.master_tidy   as c on b.docid = c.docid 
order by bbl asc, date_filed desc;
