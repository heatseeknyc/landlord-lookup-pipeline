--
-- address canonicalization for the flat 'contacts' import.
--
UPDATE flat.nychpd_registration SET streetname = regexp_replace( streetname, ' AVE$|-AVE$| -AVE$', ' AVENUE') WHERE streetname ~ '.*(AVE$|-AVE$| -AVE$)';
UPDATE flat.nychpd_registration SET streetname = regexp_replace( streetname, '\.', '', 'g');
UPDATE flat.nychpd_registration SET streetname = array_to_string(regexp_matches(streetname, '(.*)(\d+)(?:TH|RD|ND|ST)( .+)'), '') WHERE streetname ~ '.*(\d+)(?:TH|RD|ND|ST)( .+).*';

UPDATE flat.nychpd_registration SET streetname = regexp_replace( streetname, ' LA$', ' LANE', 'g');
UPDATE flat.nychpd_registration SET streetname = regexp_replace( streetname, ' LN$', ' LANE', 'g');
UPDATE flat.nychpd_registration SET streetname = regexp_replace( streetname, ' PL$', ' PLACE', 'g');
UPDATE flat.nychpd_registration SET streetname = regexp_replace( streetname, ' ST$| STR$', ' STREET', 'g');
UPDATE flat.nychpd_registration SET streetname = regexp_replace( streetname, ' RD$', ' ROAD', 'g');
UPDATE flat.nychpd_registration SET streetname = regexp_replace( streetname, ' PKWY$', 'PARKWAY', 'g');
UPDATE flat.nychpd_registration SET streetname = regexp_replace( streetname, ' PKWY ', ' PARKWAY ', 'g');
UPDATE flat.nychpd_registration SET streetname = regexp_replace( streetname, ' BLVD$', ' BOULEVARD', 'g');
UPDATE flat.nychpd_registration SET streetname = regexp_replace( streetname, ' BLVD ', ' BOULEVARD ', 'g');
UPDATE flat.nychpd_registration SET streetname = regexp_replace( streetname, '^BCH ', 'BEACH ', 'g');

UPDATE flat.nychpd_registration SET streetname = regexp_replace( streetname, '^E ', 'EAST ');
UPDATE flat.nychpd_registration SET streetname = regexp_replace( streetname, '^W ', 'WEST ');
UPDATE flat.nychpd_registration SET streetname = regexp_replace( streetname, '^N ', 'NORTH ');
UPDATE flat.nychpd_registration SET streetname = regexp_replace( streetname, '^S ', 'SOUTH '); 

-- Old-style street names. 
UPDATE flat.nychpd_registration SET streetname = 'DEKALB AVENUE' where streetname = 'DE KALB AVENUE';
UPDATE flat.nychpd_registration SET streetname = 'MACDOUGAL STREET' where streetname = 'MAC DOUGAL STREET';

