
Notes about BIN quirks across various data sources.

Provenance
----------

In theory, BINs are assigned by the DCP's Geographic Support Services (GSS) unit.


"Million" BINs
--------------

The so-called "million" BINs (1000000,2000000,3000000,4000000,5000000) are notorious
throughout the NYC property data ecosystem.  Unlike the "billion" BBLs, they don't simply 
denote error conditions but have semantic significance, and are returned by Geoclient
in many cases (e.g. for vacant lots); they also are the "official" BINs for a small but 
dwindling number of buildings (2112 as of Pluto 16v2).

In any case, in our data model such BINs are described as *degenerate*, and are assigned
a *bintype* of 2.


Weird Cases
-----------

Some weird cases of BINs or BBL/BIN pairings throughout the various datasets (or not-so 
weird, really, because variants of these situations occur all the time). 


