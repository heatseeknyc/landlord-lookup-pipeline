drop view if exists meta.acris_history cascade; 
create view meta.acris_history as
select 
  a.bbl, b.docid, b.easement, b.partial, 
  c.doctag,c.doctype,c.amount,c.date_filed,c.date_modified  
from push.pluto as a
left join push.acris_legals  as b on a.bbl = b.bbl
inner join push.acris_master as c on b.docid = c.docid;
