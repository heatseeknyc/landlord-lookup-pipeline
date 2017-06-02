begin;

create index on push.nychpd_building(id);
create index on push.nychpd_building(bbl);
create index on push.nychpd_building(bin);
create index on push.nychpd_building_count(bbl);

create index on push.nychpd_registration(id);
create index on push.nychpd_registration(bbl);
create index on push.nychpd_registration(building_id);
-- create index on push.nychpd_registration(house_number,street_name,zip);
-- create index on push.nychpd_registration(house_number,street_name,boro_id);

create index on push.nychpd_contact(id);
create index on push.nychpd_contact(contact_type);
create index on push.nychpd_contact(registration_id);
create index on push.nychpd_contact_rank(contact_type);

create index on push.nychpd_legal(id);
create index on push.nychpd_legal(bbl);
create index on push.nychpd_legal(building_id);

create index on push.nychpd_complaint(id);
create index on push.nychpd_complaint(building_id);
create index on push.nychpd_complaint(bbl);

create index on push.nychpd_violation(id);
create index on push.nychpd_violation(building_id);
create index on push.nychpd_violation(registration_id);
create index on push.nychpd_violation(bbl);

commit;
