--
-- Finally, grant access to our readuser on the hard schema.
--

begin;

grant usage on schema hard to readuser;
grant select on all tables in schema hard to readuser;

commit;

