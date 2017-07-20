
begin;

-- Loading + Procesing schema
drop schema if exists flat cascade; create schema flat; 
drop schema if exists core cascade; create schema core; 
drop schema if exists push cascade; create schema push; 
drop schema if exists meta cascade; create schema omni; 
drop schema if exists meta cascade; create schema meta; 

-- Output schema.  These are the only ones that get exported to
-- the gateway, and the only ones to which the 'readuser' has access.
drop schema if exists hard cascade; create schema hard; 
drop schema if exists deco cascade; create schema deco; 

-- Special scheme, used for exports or ad-hoc imports 
drop schema if exists norm cascade; create schema norm;

commit;

