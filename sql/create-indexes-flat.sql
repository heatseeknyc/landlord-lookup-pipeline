--
-- For the loading phase we index columns we need for address
-- scrubbing and such, + some basic aggregation used by the views 
-- in the 'core' schema.
--

begin;
create index on flat.contacts(registrationcontactid);
create index on flat.contacts(contacttype);
create index on flat.contacts(registrationid);
create index on flat.registrations(registrationid);
create index on flat.registrations(buildingid);
create index on flat.registrations(housenumber,streetname,zip);
create index on flat.registrations(housenumber,streetname,boroid);
create index on flat.mapdata(bbl);
create index on flat.taxbills(bbl);

-- presently these are needed for the scrubbing phase only.
create index on flat.registrations(streetname);
create index on flat.contacts(businessstreetname);
create index on flat.contacts(businesshousenumber);
create index on flat.contacts(businessapartment);
commit;

