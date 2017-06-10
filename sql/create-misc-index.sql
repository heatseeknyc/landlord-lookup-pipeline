--
-- Indexes just the columns we need for aggregation + analysis.
--

begin;

create index on push.misc_stable_confirmed(bbl);
create index on push.misc_joined(bbl);
create index on push.misc_joined(bbl,year);
create index on push.misc_joined(bbl,in_dhcr);
create index on push.misc_joined(bbl,estimate);

commit;
