--
-- Indexes just the columns we need for aggregation + analysis.
--

begin;

create index on push.nychpd_contacts(id);
create index on push.nychpd_contacts(contact_type);
create index on push.nychpd_contacts(registration_id);
create index on push.nychpd_registrations(id);
create index on push.nychpd_registrations(bbl);
create index on push.nychpd_registrations(building_id);
create index on push.nychpd_registrations(house_number,street_name,zip);
create index on push.nychpd_registrations(house_number,street_name,boro_id);
create index on push.nychpd_contact_rank(contact_type);
create index on push.pluto_taxlot(bbl);
create index on push.pluto_building(bbl,bin);
create index on push.pluto_building_primary(bbl,bin);
create index on push.stable(bbl);

commit;
