--
-- Address canonicalization NYC HPD contacts. 
--
UPDATE flat.hpd_contact SET businessstreetname = regexp_replace( businessstreetname, ' AVE$|-AVE$| -AVE$', ' AVENUE') WHERE businessstreetname ~ '.*(AVE$|-AVE$| -AVE$)';
UPDATE flat.hpd_contact SET businessstreetname = regexp_replace( businessstreetname, '^ST.? ', 'SAINT ', 'g') WHERE businessstreetname ~  '^ST.? .*';
UPDATE flat.hpd_contact SET businessstreetname = regexp_replace( businessstreetname, '\.', '', 'g');
UPDATE flat.hpd_contact SET businessstreetname = array_to_string(regexp_matches(businessstreetname, '(.*)(\d+)(?:TH|RD|ND|ST)( .+)'), '') WHERE businessstreetname ~ '.*(\d+)(?:TH|RD|ND|ST)( .+).*';

UPDATE flat.hpd_contact SET businessstreetname = regexp_replace( businessstreetname, ' LA$', ' LANE', 'g');
UPDATE flat.hpd_contact SET businessstreetname = regexp_replace( businessstreetname, ' LN$', ' LANE', 'g');
UPDATE flat.hpd_contact SET businessstreetname = regexp_replace( businessstreetname, ' PL$', ' PLACE', 'g');
UPDATE flat.hpd_contact SET businessstreetname = regexp_replace( businessstreetname, ' ST$| STR$', ' STREET', 'g');
UPDATE flat.hpd_contact SET businessstreetname = regexp_replace( businessstreetname, ' RD$', ' ROAD', 'g');
UPDATE flat.hpd_contact SET businessstreetname = regexp_replace( businessstreetname, ' PKWY$', 'PARKWAY', 'g');
UPDATE flat.hpd_contact SET businessstreetname = regexp_replace( businessstreetname, ' PKWY ', ' PARKWAY ', 'g');
UPDATE flat.hpd_contact SET businessstreetname = regexp_replace( businessstreetname, ' BLVD$', ' BOULEVARD', 'g');
UPDATE flat.hpd_contact SET businessstreetname = regexp_replace( businessstreetname, ' BLVD ', ' BOULEVARD ', 'g');
UPDATE flat.hpd_contact SET businessstreetname = regexp_replace( businessstreetname, '^BCH ', 'BEACH ', 'g');

UPDATE flat.hpd_contact SET businessstreetname = regexp_replace( businessstreetname, '^E ', 'EAST ');
UPDATE flat.hpd_contact SET businessstreetname = regexp_replace( businessstreetname, '^W ', 'WEST ');
UPDATE flat.hpd_contact SET businessstreetname = regexp_replace( businessstreetname, '^N ', 'NORTH ');
UPDATE flat.hpd_contact SET businessstreetname = regexp_replace( businessstreetname, '^S ', 'SOUTH ');

UPDATE flat.hpd_contact SET businessapartment = regexp_replace( businessapartment, '_|\.', '', 'g');

-- remove spaces between floor
UPDATE flat.hpd_contact SET businessapartment = array_to_string(regexp_matches( businessapartment, '(.*)(\d+)(?:TH|RD|ND|ST)?(?: ?)(FL)R?'), '') where businessapartment ~ '.*(\d+)(?:TH|RD|ND|ST)?(?: ?)(FL)R?.*';

-- remove dashes or spaces. Sorry Queens!
UPDATE flat.hpd_contact SET businesshousenumber = regexp_replace( businesshousenumber, '-| ', '', 'g');

