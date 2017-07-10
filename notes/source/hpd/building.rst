Notes about the "Buildings under HPD jurisdiction" dataset.

The ``buildings`` table is actually a series of internal building registration records 
(where "registration" here has a different meaning than HPD contact registration).
Most rows are unique to a given (BBL,BIN) pair but a good number (about 8%) are many-to-1
on this key.  There are also a fair number of dirty BBLs/BINs, and a small portion 
are either marked as 'Inactive'/'Pending' and/or show the building as 'Demolished' or
merely 'Planned'.

Some quick stats:

  select count(*) from push.hpd_building;         311065    # all rows
  select count(*) from push.hpd_building_regular; 305199    # clean BBLs/BINs only
  select count(*) from push.hpd_building_active;  294048    # status=active and building currently exists 

  select count(distinct(bbl,bin)) from push.hpd_building_active; 292253

To keep things simple we'll only be interested in the later (``_active``) rowset;
from there we just need to get an idea of what meaning thre is to the 1795 rows that 
are many-to-1 on (BBL,BIN), and to what extent their dependent column vary on 
this key (and how we can best derive an aggregation that's 1-1 on the the key).

That should be easy because at this stage, we're only interested in one dependent
column, ``program``.  The ``registration_id`` is apparently provided by the  
contact registration tables, which should be our authority for that relationship.
And we don't know much about the ``legal`` fields, so we'll get back to those later.
In any case the goal will be to emit a sequence of tuples 

    (bbl,bin,program)

Where ``(bbl,bin)`` are unique.   

Fortunately this will turn out to be easy because after the various restrictions 
above, there aren't too many rows left which have variance on this column:

  select bbl,bin,count(distinct program) from push.hpd_building_active group by bbl,bin having count(distinct program) > 1;
      bbl     |   bin   | count 
  ------------+---------+-------
   1001420025 | 1083239 |     2
   2024400001 | 2091242 |     2
   5009550001 | 5113197 |     2
  (3 rows)

Ad if you look at their repeating forms, it seems pretty clear that the "duplicate" records are most likely updates: 

    id   |    bbl     |   bin   |    program     | dob_class_id | legal_stories | legal_class_a | legal_class_b | lifecycle | status_id 
 --------+------------+---------+----------------+--------------+---------------+---------------+---------------+-----------+-----------
  804897 | 1001420025 | 1083239 | M-L (NRF CITY) |            5 |             2 |             8 |             0 | Building  |         1
  804920 | 1001420025 | 1083239 | PVT            |            5 |             4 |            14 |             0 | Building  |         1
  812817 | 1001420025 | 1083239 | PVT            |           25 |             2 |             2 |             0 | Building  |         1
  806839 | 2024400001 | 2091242 | PVT            |            5 |             6 |           160 |             0 | Building  |         1
  806840 | 2024400001 | 2091242 | M-L (NRF CITY) |            5 |             6 |            80 |             0 | Building  |         1
  812511 | 5009550001 | 5113197 | CENTRAL MGT |           23 |             1 |             1 |             0 | Building  |         1
  812557 | 5009550001 | 5113197 | PVT         |           23 |             0 |             0 |             0 | Building  |         1


So our solution will be to simply self-join on the most recent record ID (the ``id`` column).
For want of a better name, we'll tall this table ``hpd_building_current`` and it's definied thusly:

  create table push.hpd_building_current as  
  select 
     a.bbl, a.bin, b.id, b.program, 
     b.dob_class_id, b.legal_stories, b.legal_class_a, b. legal_class_b
  from      push.hpd_building_count  as a
  left join push.hpd_building_active as b on (a.bbl,a.bin,a.last_id) = (b.bbl,b.bin,b.id);
  (292253 rows)

Note that while we don't need the 4 columns that appear afer the ``program`` column, but we might
as well slot them in at this stage, anyway.

Some quick stats about this rowset: About 98.5% of the BBLs in this set occur uniquely (that is, have only one 
associated BIN), with some 4k BBLs that have more than one BIN (across some 15k rows)::

   select count(distinct bbl) from push.hpd_building_current;                                                       280520
   select count(*) from (select bbl,count(*) from push.hpd_building_current group by bbl having count(*) = 1) as x; 276574
   select count(*) from (select bbl,count(*) from push.hpd_building_current group by bbl having count(*) > 1) as x;   3946 

And though we didn't specifically exclude them, it turns out there are no ``marginal`` BBLs in this set::

   select count(distinct bbl) from push.hpd_building_current where is_marginal_bbl(bbl);


Finally we create a ``tidy`` view that restricts to just the ``program`` column (along with the 3 key columns),
and aggregates those values into a smaller set that's eaiser to get some perspective on (grouping the 3 Mitchell-Lama
values, and throwing anythings besides ``NYCHA``, ``7A`` or ``LOFT LAW`` (or ``PVT``) into ``OTHER`` (which shall 
signify "HPD managed, of some other type").

For want of a better name, we'll call this table ``hpd_building_program`` and it gets a lot closer to the final
outgoing table (``hpd_taxlot_program``) that will get slotted into ``hard`` schema.  Here's what the breakdown 
looks like, going by the field values above::

  select program, count(*) from push.hpd_building_program group by program;                                                                              
   program  | count  
  ----------+--------
            |      8
   7A       |     30
   NYCHA    |   2177
   LOFT LAW |    226
   M-L      |    666
   OTHER    |    350
   PVT      | 288796


Outliers
--------

Before moving on we'd like to check to what extent the HPD set of (BBL,BIN) pairs 
overlaps with the PAD/Pluto set.  The view ``omni.hpd_building_extra`` provides this 
difference set.  We were hoping there'd be only a few rows in this set, but 
we were wrong:

   select count(*) from omni.hpd_building_extra; 7647
   select count(distinct bbl) from omni.hpd_building_extra; 7314
   select count(distinct bbl) from omni.hpd_building_extra where is_condo_bbl(bbl); 916; 

So presumably most of these are misalignments of (bbl,bin) due to confusion between  
the "bank" and "physical" bbls.  Nonetheless a fair number of these BBLs don't exist 
in PAD/Pluto at all:

   select count(*) from omni.hpd_building_badlot; 1748

What's with these lots?  Many are in ACRIS it seems like this one:

   1000970011 - sold for $7,300,000 on 2013-01-17; docid = 2012123100033001

Apparently it's not part of a condo declaration; but at least we know the address of the lot (and of related lots in that transaction):

   select * from push.acris_legal where docid = '2012123100033001';
         docid       |    bbl     | easement | partial | rights_air | rights_sub | proptype |  street_name   | street_number | unit | date_valid_thru 
   ------------------+------------+----------+---------+------------+------------+----------+----------------+---------------+------+-----------------
    2012123100033001 | 1000970011 | f        | E       | f          | f          | CR       | SOUTH STREET   | 105           |      | 2015-07-31
    2012123100033001 | 1000970010 | f        | E       | f          | f          | CR       | SOUTH STREET   | 106           |      | 2015-07-31
    2012123100033001 | 1000970012 | f        | E       | f          | f          | CR       | BEEKMAN STREET | 154           |      | 2015-07-31
   (3 rows)


Turns out most of these are in ACRIS, but there are some 422 "stragglers", or which 366 look like bank BBLs for condo lots:

    select count(*) from omni.hpd_building_stragglers;                         422
    select count(*) from omni.hpd_building_stragglers where is_condo_bbl(bbl); 366

The "condo" lots appear to be outdated/incorrect lot numbers for other condos on the same block. 

That leaves 56 "vanilla" stragglers.  Turns out most of these are in SI (and around half belong
to a single block in that borough, 3472).  The rest are presumably typos or marginal demapped lots. 


Back to the program column 
--------------------------

Now that we've derived a relation for the ``program`` column that's unique to a (BBL,BIN) pair, we'd still 
like to know to whether this column aggregates cleanly enough on BBL.  Some quick stats, using a counting
view ``hpd_program_count``:

    select count(distinct bbl) from push.hpd_building_program;      280520
    select count(*) from push.hpd_program_count where program = 1;  280476
    select count(*) from push.hpd_program_count where program > 1;      38


Turns out that of the 38 BBLs for which ``program`` occurs multiply, we presently (June 2017) see just two
programs -- always ``PVT`` or some other program.  That is, while for some taxlots registered in special 
programs there might be additional buildings that aren't part of that program (hence, flagged as ``PVT``) --
so far there's at most one special program per lot.  That is, here are no lots under "joint" administration
between competing HPD programs.

So the solution for now is, to gloss over details, to create a rowset which identifies a BBL with either  
a unique (for that BBL) special program, or NULL for either no program (or formerly, ``PVT``).  Again, we'll
skip the details other than to say that it requires a self-join in a natural-enough seeing way.  And is 
provided by the ``hpd_taxlot_program`` whose rowcounts align with the following sanity checks: 

    # First count distinct BBLs, then BBLs w/ special programs in the primary table
    select count(distinct bbl) from push.hpd_building_program;                                                 280520
    select count(distinct bbl) from push.hpd_building_program where program is not null and program != 'PVT';    1736

    # And the same checksums on our derived table 
    select count(*) from push.hpd_taxlot_program;                                                              280520
    select count(*) from push.hpd_taxlot_program where program is not null;                                      1736

Here's the internal breakdown with of the ``program`` column within that table::

    select program,count(*) from push.hpd_taxlot_program group by program;
     program  | count  
    ----------+--------
              | 278784
     7A       |     30
     OTHER    |    321
     LOFT LAW |    224
     M-L      |    306
     NYCHA    |    855
     (6 rows)

We now have a table that can be slotted into the the view ``meta.taxlot`` for our final outgoing "hard" table. 

Other Details
-------------

A couple of final notes on the above:

(1) We suspect there's still a lot missing in the HPD's special program designations. 
For example, the count for NYCHA lots falls short by some 200+ that we've seen in at least one other 
list we've seen for NYCHA lots (though that list may include vacant lots).  But it's a start.

(2) There's some significant overlap between the "special programs list" and the most recent (2015) 
combined stabilization list:

   
    select count(*) 
    from push.stable_combined as a 
    left join push.hpd_taxlot_program as b on a.bbl = b.bbl where b.program is not null;       67

Of these we have 50 in the DHCR list, 17 in taxbills.  Looks like they're spread across the various 
programs ('NYCHA','M-L','LOFT LAW','7A') with some preference for 7A.  In any case, from what we've
understood the DHCR list (at least) was supposed to exclude special HPD programs (at least NYCHA
and M-L in any case).

So when we do the final aggregation across the various stabilization lists, it looks like the 
HPD designations will take precedence (the DHCR/taxbill lists being "unmarked").





