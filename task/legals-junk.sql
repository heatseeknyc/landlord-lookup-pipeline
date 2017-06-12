
select docid,bbl from push.acris_legals 
where (public.bbl2block(bbl) > 90000 or public.bbl2block(bbl) = 9999) and public.bbl2lot(bbl) < 9990
order by bbl desc, docid desc; 

