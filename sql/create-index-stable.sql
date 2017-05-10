--
-- Indexes just the columns we need for aggregation + analysis.
--

begin;

create index on push.stable(bbl);
create index on push.stable_joined(bbl);
create index on push.stable_joined(bbl,year);
create index on push.stable_joined(bbl,in_dhcr);
create index on push.stable_joined(bbl,estimate);

commit;
