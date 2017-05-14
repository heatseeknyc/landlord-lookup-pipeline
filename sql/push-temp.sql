
begin;

drop schema if exists kool cascade;
create schema kool;

drop table if exists kool.endangered_taxlots; 
create table kool.endangered_taxlots as
select * from temp.endangered_taxlots order by bbl;

drop table if exists kool.endangered_buildings; 
create table kool.endangered_buildings as
select * from temp.endangered_buildings order by bbl, bin;

create index on kool.endangered_taxlots(bbl);
create index on kool.endangered_buildings(bbl,bin,council);

commit;
