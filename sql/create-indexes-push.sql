--
-- Indexes just the columns we need for aggregation + analysis.
--

begin;

create index on push.contacts(id);
create index on push.contacts(contact_type);
create index on push.contacts(registration_id);
create index on push.registrations(id);
create index on push.registrations(bbl);
create index on push.registrations(building_id);
create index on push.registrations(house_number,street_name,zip);
create index on push.registrations(house_number,street_name,boro_id);
create index on push.contact_rank(contact_type);
create index on push.pluto(bbl);
create index on push.buildings(bbl,bin);
create index on push.stable(bbl);

commit;
