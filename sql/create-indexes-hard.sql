--
-- Indexes just the columns we need for the REST API.
--

begin;

create index on hard.contact_info(id);
create index on hard.contact_info(bbl);
create index on hard.registrations(id);
create index on hard.registrations(bbl);
create index on hard.registrations(house_number,street_name,boro_id);
create index on hard.property_summary(bbl);

commit;

