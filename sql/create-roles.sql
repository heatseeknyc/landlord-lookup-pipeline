--
-- Following good practice, we create two roles, one for writing,
-- the other for reading.  We can't actually grant privileges for
-- the read user at this stage because the object it acts on 
-- (the 'hard' schema) hasn't been created yet; so we'll do that
-- once that schema has been created.
--
begin;
create user writeuser with password 'sekret';
create user readuser with password 'sekret';
grant all privileges on database nyc1 to writeuser;
end;

