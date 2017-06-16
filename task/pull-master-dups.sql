select * from core.acris_master_tidy 
where docid in (
    select docid from (
        select docid,count(*) from push.acris_master group by docid having count(*) > 1
    ) x
) order by docid, date_filed;
