--
-- Indexes just the columns we need for aggregation + analysis.
--

begin;

create index on push.stable_confirmed(bbl);

commit;
