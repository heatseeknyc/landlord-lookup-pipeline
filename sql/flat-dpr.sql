
--
-- NYC Department of Parks and Recreation 
--

begin;

drop table if exists flat.dpr_park_prop cascade;
create table flat.dpr_park_prop (
    the_geom text,
    GISPROPNUM text,
    LOCATION text,
    COMMUNITYB text,
    COUNCILDIS text,
    ZIPCODE text,
    BOROUGH text,
    ACRES text,
    ADDRESS text,
    SIGNNAME text,
    TYPECATEGO text,
    WATERFRONT text,
    NYS_ASSEMB text,
    NYS_SENATE text,
    US_CONGRES text
);

commit;

