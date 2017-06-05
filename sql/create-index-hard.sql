--
-- Indexes just the columns we need for the REST API.
--

begin;

create index on hard.property_summary(bbl);
create index on hard.property_summary(bbl,bin);
create index on hard.contact_info(contact_id);
create index on hard.contact_info(bbl);
create index on hard.contact_info(bbl,bin);
create index on hard.pluto_building(bbl);

commit;

