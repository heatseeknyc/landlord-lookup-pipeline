--
-- The "hard" schema contains all the tables accessed by the REST API,
-- with appropriate keys indexed (and just those columns indexed that 
-- we'll do ordered searches on).
--

begin;

drop schema if exists hard cascade;
create schema hard;

commit;

