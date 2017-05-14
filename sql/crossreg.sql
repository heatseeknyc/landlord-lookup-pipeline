begin;

drop view if exists temp.crossreg;
create view temp.crossreg as
select 
  a.bbl, 
  a.id as a_id, b.building_id as b_id,
  a.bin as a_bin, b.bin as b_bin,
  a.registration_id as regid
from push.nychpd_building as a left join push.nychpd_registration b on a.registration_id = b.id 
where (
    a.bin is null or a.bin <= 1000000 or a.bin >= 6000000 or a.bin in (2000000,3000000,4000000) or 
    a.bbl in (1000000000,2000000000,3000000000,4000000000,5000000000)
) and a.registration_id > 0;

commit;
