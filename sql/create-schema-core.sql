--
-- The 'core' schema presents views of corresponding tables 
-- in the 'flat' schema, with normalized column names, a few 
-- changes in column order, and (crucially) the introduction
-- of the 'bbl' column (representing a composite key on boro_id,
-- block and lot number).
--
begin;
drop schema if exists core cascade;
create schema core;
commit;

