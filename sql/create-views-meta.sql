begin;

--
-- Aggregation Views 
-- These end up getting mapped 1-1 with tables in the 'hard' schema.
--

-- A simplified view of push.contacts with some column names, other columns 
-- catenated for brevity / tidier reporting (and minus contact_title), and the
-- ordering rank for contact_type slotted in.
create view meta.contacts_simple as 
select 
  a.id, registration_id, a.contact_type, b.id as contact_rank, 
  contact_description as description, corporation_name as corpname, 
  public.make_contact_name(contact_first_name,contact_middle_initial,contact_last_name) as contact_name,
  public.make_contact_addr(
    business_house_number,business_street_name,business_apartment,business_city,business_state,business_zip
  ) as business_address 
from push.contacts               as a
left join push.contact_rank as b on b.contact_type = a.contact_type;

-- A crucial aggregation showing distinct tuples of (contact_id, registration_id, bbl) 
-- with building + result counts slotted in.  Since registration_id depeends strictly on 
-- contact_id, we have as an effective composite key the tuple (contact_id, bbl).
-- 
-- Note that in general, this result set will be slightly larger than our initial
-- contacts set; for example, currently we have:
--
--    select count(*) from push.contacts;         576582
--    select count(*) from meta.lookup_contacts;  577052
--
-- This is to account for the fact that certain Contact IDs are associated with more 
-- than one BBL (through their associated Reg IDs).  At the same time, we're guaranteed
-- that for a given BBL, Contact IDs will be unique throughout that result set.  
--
-- The intended use case is generally "select * where bbl = ?" which gets you a 
-- list of distinct Contact IDs, with RegIDs slotted in.
--
create view meta.lookup_contacts as
select 
  a.id as contact_id, a.registration_id, b.bbl, 
  count(distinct building_id) as building_count,
  count(*)                    as result_count
from      push.contacts      as a
left join push.registrations as b on b.id = a.registration_id
group by a.id, a.registration_id, b.bbl;


-- A front-end view (equivalent to a hard table we'll be accessing directly 
-- from the REST API) providing (basically) the same result set as above, but
-- with simplified contact info slotted in.  The idea is that you can just do
--
--   "select * where bbl = ?" 
--
-- to get simplified contact info by BBL, suitable for consumption over the 
-- REST API.
--
-- Caveats:
--
-- (1) A significant number (currently 2231) of the BBL in push.registrations 
-- will not appear in this result set (for the simple reason that none of their
-- associated Reg IDs appear in push.contacts).  Hence selects on these BBLs will 
-- turn up empty. Such BBLs are called "orphaned", and the empty result sets need 
-- to be explained to front-end users.  See the section on "Analytical Views"
-- below for some simple queries to isolate these cases.
--
-- (2) In addition, for a very small number of BBLs (currently 10), the result
-- sets will contain repeated Contact IDs with nearly identical attributes. 
-- This is due to a small number of Contact IDs appearing twice in push.contacts;
-- these are also treated in section on Analytical Views, below. 
--
create view meta.contact_info as
select a.bbl, b.*
from      meta.lookup_contacts as a
left join meta.contacts_simple as b on b.id = a.contact_id;





-- A few intermediate views (used by our last aggregation view). 

create view meta.count_registrations_by_bbl as 
select bbl, count(distinct id) as regid_count, count(distinct building_id) as building_count 
from push.registrations group by bbl;

create view meta.count_contacts_by_bbl as
select a.bbl, count(distinct b.id) as contact_count
from      push.registrations as a
left join push.contacts      as b on b.registration_id = a.id
group by a.bbl;

-- Takes care of a very small number of BBLs which have more than one 
-- cb_id for some reason (which seems to happen quite often).   
-- Joining on this view forces the cb_id to be unique to a given BBL
-- (and the ordering in the inner select forces the association to be
-- reproducible).
create view meta.first_cbid_by_bbl as
select x.bbl, first(x.cb_id) as cb_id from (
    select bbl, cb_id from push.registrations group by bbl, cb_id order by bbl, cb_id
) as x group by x.bbl;

-- A final, crucial joining view providing all the basic, high-level 
-- information we currently provide per BBL.  It also ends up being pushed 
-- over to the 'hard' schema, and the counts are returned through the initial 
-- lookup query to inform the user whether we have an overly-large dataset 
-- to display or not.
create view meta.property_summary as
select 
  t.bbl, 
  t.owner_name      as taxbill_owner_name,  
  t.mailing_address as taxbill_owner_address,  
  t.active_date     as taxbill_active_date,
  a.regid_count, a.building_count, b.contact_count, 
  cast(t.bbl/1000000000 as smallint) as boro_id
from      flat.taxbills as t 
left join meta.count_registrations_by_bbl as a on a.bbl = t.bbl
left join meta.count_contacts_by_bbl      as b on b.bbl = a.bbl;



--
-- Analytical Views
--
-- These are for troubleshooting only; they help highlight corner cases 
-- in the the data that don't occur very often for users, but can throw 
-- off row counts or be difficult to troubleshoot for other reasons.
--

-- A Reg ID is said to be orphaned if it doesn't appear in push.contacts.
create view meta.orphaned_registrations as
select a.* 
from      push.registrations as a
left join push.contacts      as b on b.registration_id = a.id 
where b.id is NULL;

-- A BBL is "entirely orphaned" if all of its Reg IDs are orphaned.
create view meta.entirely_orphaned_contacts as
select * from meta.contact_info where bbl in (
  select distinct bbl from meta.count_contacts_by_bbl where contact_count = 0
);

-- A BBL is "partially orphaned" if some, but not all of its Reg IDs are orphaned.  
create view meta.partially_orphaned_bbls as
select * from meta.orphaned_registrations where bbl not in (
  select distinct bbl from meta.count_contacts_by_bbl where contact_count = 0
);

--
-- The views concern Contact IDs appearing more than once in push.contacts, which, 
-- while small in number, can throw off summaries + checksums (and be mildly confusing 
-- to end-users, when they show up in result sets.
--

-- All duplicate contact IDs (yields 13 instances in the Dec 2015 dataset).
create view meta.degenerate_contacts as 
select id, count(*) from meta.contacts_simple group by id having count(*) > 1;

--
-- Pairs of (registration_id, contact_id) appearing more than once in push.contacts.
-- Currently these are always many-to-one (i.e. sometimes multiple registration IDs per 
-- contact ID, but never the other way around); as long as this holds, contact IDs are 
-- unique in this set (and hence the row count is the number of such degenerate IDs).
--
create view meta.degenerate_contact_pairs as 
select registration_id, id as contact_id, count(*) from push.contacts where id in (
  select id from push.contacts group by id having count(*) > 1
) group by registration_id, id;


-- All result sets from meta.contact_info containing at least one degenerate contact ID.
-- Currently 62 rows over 10 BBLs.
create view meta.degenerate_contact_info as
select * from meta.contact_info where bbl in (
  select distinct bbl from push.registrations where id in (
    select distinct registration_id from meta.degenerate_contact_pairs
  )
) order by bbl;

commit;

