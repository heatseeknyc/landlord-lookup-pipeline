--
-- More aggregations of ACRIS table, culminating in that fine view,
-- 'acris_owner'.
--

begin;

drop schema if exists p2;
create schema p2;

-- select count(distinct bbl) from push.acris_legal;  1154810   all property-transaction relations 
-- select count(distinct bbl) from p1.acris_history;  1152338   "where in_master and is_regular_bbl" 
-- select count(*) from p1.acris_history_count        1152338    
-- select count(*) from p1.acris_history;            18055244


-- Date of last known conveyance (or group of conveyances) for a given lot. 
-- 993274 rows
create view p2.last_convey_date as
select bbl, max(date_filed) as date_filed
from p1.acris_history where docfam = 1 group by bbl;

-- For every property, provides a subset of acris_history restrected to proper  
-- conveyances  occuring on the last identifiable transfer date.  Usually it's just
-- one per BBL, but sometimes its many-to-1 on a BBL.
--
-- 1027650 rows
create table p2.deed_blok as
select b.* 
from      p2.last_convey_date as a
left join p1.acris_history    as b on (a.bbl,a.date_filed) = (b.bbl,b.date_filed)
where b.docfam = 1;
create index on p2.deed_blok(bbl);
-- where is_conveyance(b.doctype);


--
-- A count of distinct DEED/CORRD transactions on the last transfer date for a given 
-- property.  In the vast majority (97%) of cases it's 1, but can sometimes go quite high.  
-- Presumably these represent multi-party transactions, and/or serial "flips" of a 
-- property within a given day.
--
-- 993274 rows
create table p2.deed_count as
select bbl, count(*) as total from p2.deed_blok group by bbl;
create index on p2.deed_count(bbl);

-- Effectively "acris_history" restricted to the to the LUIT (last uniquely 
-- identifiable transfer) for that lot, when this transfer is identifiable. 
--
-- While we're at it, we slot in the number of parties on the buying side, and an
-- integer code (0,1,2) indicating whether this is a total sale (2), a partial sale (1), 
-- or a sale of unknown type (0).  We call this column "whole", for the "wholeness" 
-- of the sale.  BTW our interpretation of "unknown type" means that most likely it 
-- was really a regular, entire sale but we present the status anyway in case someone 
-- wants to make a different interpretation of it.
--
-- In other words, a list of LUITs for a given lot (with buyer counts),
-- for lots where these can be identified. 
--
-- 964736 rows 
-- drop table if exists p2.last_deed cascade; 
create table p2.last_deed as
select 
    b.*, 
    c.total as buyers,
    case 
        when b.percentage = 100 then 2   -- total sale
        when b.percentage >   0 then 1   -- partial sale
        else 0                           -- "unknown" 
    end as whole 
from      p2.deed_count          as a
left join p2.deed_blok           as b on a.bbl = b.bbl
left join push.acris_party_count as c on b.docid = c.docid
where a.total = 1 and c.party_type = 2;
create index on p2.last_deed(docid);
create index on p2.last_deed(bbl);

--
-- A couple of notes:
--
--   - "deed_count" refers to the number of conveyance-like transactions on the 
--     last date (for that bbl) such transactions occcured.
--
--   - the "buyers" and "part" fields are only available when there's an LUIT, that is, 
--     when deed_count = 1.
--
-- 1152338 rows
--
create table p2.convey_origin as
select
    a.bbl, c.date_filed, c.doctype, c.docfam,
    coalesce(b.total,0) as deed_count, 
    c.buyers, c.whole, c.docid,
    case
        when b.total is null then 0  -- no deeds at all for this lot 
        when b.total > 1 then 3      -- has deeds, but last deed not uniquely identifiable (no LUIT)
        when c.whole = 1 then 2      -- has LUIT, but for a partial sale
        else 1                       -- vanilla case - LUIT for presumed total sale
    end as class
from p1.acris_history_count     as a
left join p2.deed_count         as b on a.bbl = b.bbl
left join p2.last_deed          as c on a.bbl = c.bbl;
create index on p2.convey_origin(bbl);

create view p2.acris_owner as
select 
    a.*, 
    b.amount, b.percentage as percent,
    case
        when buyers is null then null
        when buyers = 1 then c.name
        else 'MULTIPARTY'
    end as name,
    case
        when buyers = 1 and (c.address1 is not null or c.address2 is not null) then 
            mkaddr_acris(c.address1,c.address2,c.country,c.city,c.state::text,c.postal)
        when buyers = 1 then 'unknown address'
        else null
    end as address
from p2.convey_origin             as a
left join push.acris_master       as b on a.docid = b.docid
left join push.acris_party_s1ngle as c on (a.docid,2) = (c.docid,c.party_type);

commit;

