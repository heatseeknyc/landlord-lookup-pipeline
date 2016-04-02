--
-- The 'meta' schema provides two crucial aggregation views which 
-- end up getting mapped 1-1 into the 'hard' schema, as well as a few 
-- analytical views which are useful for internal troubleshooting 
-- (but which aren't accessed by the service layer).
--
begin;
drop schema if exists meta cascade;
create schema meta;
commit;

