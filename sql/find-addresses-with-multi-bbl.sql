
--
-- Finds registration rows associated with addresses which resolve to 
-- more than BBL per tuple of (house_number,street_name,zip). Currently 
-- (in the 20151130 dataset) this rowset is quite small (40 rows).
--
select 
b.id, b.bbl, a.total, c.total as contacts,
b.building_id, b.house_number, b.house_number_low, b.house_number_high, b.street_name, b.zip, b.bin
from      meta.count_bbl_by_address as a
left join push.registrations        as b on (
    b.house_number = a.house_number AND
    b.street_name  = a.street_name  AND
    b.zip          = a.zip
) 
left join meta.count_contacts_by_regid as c on c.registration_id = b.id
where a.total > 1
order by street_name, house_number, zip;

