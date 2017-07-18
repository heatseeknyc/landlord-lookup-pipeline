--
-- Finally, grant access to our readuser on the 'hard' and 'deco' schemas.
--

begin;

grant usage on schema hard to readuser;
grant select on all tables in schema hard to readuser;

grant usage on schema deco to readuser;
grant select on all tables in schema deco to readuser;

commit;

