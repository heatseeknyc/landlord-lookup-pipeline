begin;

/* 
create index on push.hpd_building(id);
create index on push.hpd_building(bbl);
create index on push.hpd_building(bin);
create index on push.hpd_building_count(bbl);

create index on push.hpd_registration(id);
create index on push.hpd_registration(bbl);
create index on push.hpd_registration(building_id);
*/
-- create index on push.hpd_registration(house_number,street_name,zip);
-- create index on push.hpd_registration(house_number,street_name,boro_id);

/*
create index on push.hpd_contact(id);
create index on push.hpd_contact(contact_type);
create index on push.hpd_contact(registration_id);
create index on push.hpd_contact_rank(contact_type);

create index on push.hpd_legal(id);
create index on push.hpd_legal(bbl);
create index on push.hpd_legal(building_id);

create index on push.hpd_complaint(id);
create index on push.hpd_complaint(building_id);
create index on push.hpd_complaint(bbl);

create index on push.hpd_violation(id);
create index on push.hpd_violation(building_id);
create index on push.hpd_violation(registration_id);
create index on push.hpd_violation(bbl);
*/

commit;
