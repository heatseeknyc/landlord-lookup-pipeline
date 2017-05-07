
begin;
create index on push.pluto_taxlot(bbl);
create index on push.pluto_building(bbl,bin);
create index on push.pluto_building_primary(bbl,bin);
create index on push.pluto_refdata_bldgclass(tag);
create index on push.pluto_refdata_landuse(tag);
commit;

