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

Further Details
---------------

More information on how the DHCR lists were obtain, scraped and processed can be found here:

    https://github.com/wstlabs/dhcr2015

And information about JK's taxbill scrapes can be found here:

    http://taxbill.nyc/






