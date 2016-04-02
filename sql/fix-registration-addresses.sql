--
-- address canonicalization for the flat 'contacts' import.
-- formerly 'registrations_clean_up.sql' in ziggy's project.
--
UPDATE flat.registrations SET streetname = regexp_replace( streetname, ' AVE$|-AVE$| -AVE$', ' AVENUE') WHERE streetname ~ '.*(AVE$|-AVE$| -AVE$)';
UPDATE flat.registrations SET streetname = regexp_replace( streetname, '\.', '', 'g');
UPDATE flat.registrations SET streetname = array_to_string(regexp_matches(streetname, '(.*)(\d+)(?:TH|RD|ND|ST)( .+)'), '') WHERE streetname ~ '.*(\d+)(?:TH|RD|ND|ST)( .+).*';

UPDATE flat.registrations SET streetname = regexp_replace( streetname, ' LA$', ' LANE', 'g');
UPDATE flat.registrations SET streetname = regexp_replace( streetname, ' LN$', ' LANE', 'g');
UPDATE flat.registrations SET streetname = regexp_replace( streetname, ' PL$', ' PLACE', 'g');
UPDATE flat.registrations SET streetname = regexp_replace( streetname, ' ST$| STR$', ' STREET', 'g');
UPDATE flat.registrations SET streetname = regexp_replace( streetname, ' RD$', ' ROAD', 'g');
UPDATE flat.registrations SET streetname = regexp_replace( streetname, ' PKWY$', 'PARKWAY', 'g');
UPDATE flat.registrations SET streetname = regexp_replace( streetname, ' PKWY ', ' PARKWAY ', 'g');
UPDATE flat.registrations SET streetname = regexp_replace( streetname, ' BLVD$', ' BOULEVARD', 'g');
UPDATE flat.registrations SET streetname = regexp_replace( streetname, ' BLVD ', ' BOULEVARD ', 'g');
UPDATE flat.registrations SET streetname = regexp_replace( streetname, '^BCH ', 'BEACH ', 'g');

UPDATE flat.registrations SET streetname = regexp_replace( streetname, '^E ', 'EAST ');
UPDATE flat.registrations SET streetname = regexp_replace( streetname, '^W ', 'WEST ');
UPDATE flat.registrations SET streetname = regexp_replace( streetname, '^N ', 'NORTH ');
UPDATE flat.registrations SET streetname = regexp_replace( streetname, '^S ', 'SOUTH '); 

-- Old-style street names. 
UPDATE flat.registrations SET streetname = 'DEKALB AVENUE' where streetname = 'DE KALB AVENUE';
UPDATE flat.registrations SET streetname = 'MACDOUGAL STREET' where streetname = 'MAC DOUGAL STREET';

