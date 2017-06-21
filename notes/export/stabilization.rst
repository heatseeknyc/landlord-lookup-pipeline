Notes about exported datasets having to do with rent stabilization. 

Currently we have two datasets available for export:
 
    export/stable_confirmed_restricted.csv   |  46441 data rows 
    export/stable_confirmed_withorphans.csv  |  47260 data rows 

Each dataset represents a "union" (a full outer join) of the two major datasets 
currently available for rent stabilization (per BBL) to the extent to which each
set can be cleanly parsed and scraped:

 - The DHCR 2015 Rent Stabilization list 
 - JK's taxbill scrapes 2007-105

Some basic caveats as the source datasets:

 - Both datasets were restricted to *structurally valid* BBLs before joining --
   that is, rejecting any obviously invalid BBLs (block or lot values all 9s or 0s).
 - The ``restricted`` dataset was further constrained to exclude rows with BBLs that 
   could not be matched in Pluto 16v2 (dropping some 813 rows).
 - While the ``withorphans`` retains such rows (on the theory that perhaps some day
   some of these BBLs can be fixed or updated).

Finally, because the lists were fundamentally different in the type of entity they 
attempted keep track of -- the DHCR list tracking buildings (sometimes many to a lot),
while the Taxbill dataset (by definition) tracks stabilization by taxlot (grouping 
unit counts across buildings) -- it was necessary to aggregate the DHCR list before 
(that is, group by BBL) before the two could be joined.  

While the aggregation in the DHCR list as ultimately somewhat ad-hoc (effectively
collapsing sometimes contradictory attibutes for each many-to-1 lot), it was completely
unavoidable if the two datasets were to be joined (and in any case affects only about
3 percent of the total set of BBLs).


Column Description
------------------

Column descriptions should hopefully be self-explantor, once one takes a minute to 
digest the nature of the joining process described above.  In any case, just to make 
things as clear as possible:

 - Aside from the BBL (which every row has, and which occurs uniquely throughout 
   the files), all column names are explicitly tagged with a prefix (``dhcr_`` or ``taxbill_``)
   according to which dataset they come from.
 - Further, the presence in each source dataset can be determined unambiguously from  
   two special columns in each dataset, which by definition can be non-NULL *if and only if*
   the associated BBL was present in the respective original dataset:
 - ``dhcr_bldg_count`` will be non-NULL *if and only if* that rows was present in the DHCR list.
 - ``taxbill_lastyear`` will be non-NULL *if and only if* that row was present in the taxbill scrapes
   (and had non-zero unitcount for at least one of the years 2007-2015).
 - The other columns were slotted-in as-is from the original datasets (noting that some of them
   may therefore somtimes be NULL even though the row was present in the source dataset).

As an illustration, here's a random select of 10 rows from the SQL perspective::

  select * from push.stable_combined order by bbl limit 10;

      bbl     | dhcr_bldg_count | dhcr_421a | dhcr_j51 |       dhcr_special  | taxbill_lastyear | taxbill_unitcount | taxbill_abatements 
  ------------+-----------------+-----------+----------+---------------------+------------------+-------------------+--------------------
   1000077501 |               1 | f         | f        | ["GARDEN COMPLEX"]  |             2015 |                 8 | 
   1000087501 |                 |           |          |                     |             2010 |                97 | 
   1000150022 |               1 | t         | f        |                     |             2015 |                 1 | 
   1000157501 |                 |           |          |                     |             2013 |                 1 | 
   1000160003 |               1 | f         | f        |                     |                  |                   | 
   1000160015 |               1 | t         | f        |                     |             2015 |               208 | 
   1000160020 |               1 | t         | f        |                     |             2015 |               209 | 
   1000160180 |               1 | f         | f        |                     |             2015 |               293 | 
   1000160185 |                 |           |          |                     |             2015 |               251 | 421a
   1000160195 |               1 | t         | f        |                     |             2015 |               274 | 

So the CSV you get will contain exactly the same fields as you see above 
(except of course presented as CSV, not fixed-width).  Hopefully it should be
clear enough that out of the 10 BBLs randomly selected, 7 had entries in the 
DHCR list, 9 had entries in the taxbill scrapes.

Finally some random "fun facts" about the row counts in each:
  - Of the 813 "orphaned" rows (not matching in Pluto) 644 were orphaned in the DHCR list, 
    while there were some 335 orphans in the taxbill list.
  - That leaves counts of 39283 and 44472 rows for each dataset respectively, among which:
  - ``dhcr`` - ``taxbills`` = 1969 rows
  - ``taxbills`` - ``dhcr`` = 7158 rows

The former discrepancy is somewhat expected because the DHCR list apparently covers certain abatement categories
that the taxbill dataset does not.  However the gap in "pre-1974" buildings implied by the latter discrepancy (taxbills - dhcr),
which amounts to about 20% of the size of the full DHCR list, is somewhat more surprising, and should be further 
investigated.


Further Details
---------------

More information on how the DHCR lists were obtain, scraped and processed can be found here:

    https://github.com/wstlabs/dhcr2015

And information about JK's taxbill scrapes can be found here:

    http://taxbill.nyc/



