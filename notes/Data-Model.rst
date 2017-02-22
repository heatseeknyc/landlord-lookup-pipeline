===========================================
Data Model for the NYC Landlord Lookup Tool
===========================================

High level description of primary data sources, ETL pipeline, and the internal data model as such. 

Primary Sources 
===============

From the perspective of the frontend client, holisitically speaking the data we use
has two main components -- which we'll refer to as the "hot" and "cold" components.

The "cold" component is a simple Postgres database which resides behind the 
REST gateway, and represents a cleansed and normalized aggregation of the following 
4 datasets from various city agencies:
- Taxbill scrapes, courtesy of taxbills.nyc
- HPD registered contacts
- DHCR rent stabilization
- MAPPluto 16v2

The exact origin of these datasets is described in more detail in the `Data Acquisition <Data-Acquisition.rst>` note.

The "hot" component is the NYC Geoclient API, an external service provided by the City of New York.

Within the running application, the NYC Geoclient API is always accessed 
dynamically (that is, its results are never cached or ETL'd into a local 
table); hence it is conceptually thought of as a "hot" data source.

It's also are sole authority address geocoding and property identifier 
(BBL+BIN) lookup, which we use to join on the latter 4 previously loaded
(or "cold") data sources.  How exactly these sources are loaded, filtered
and normalized is described in the next section.

ETL Pipeline
============

It is the 3 "cold" sources above that comprise the scope of the  
data pipeline implemented in this repo.

Basically these 3 sources after first being manually downloaded from
their archival sources (as described in special notes for each) are ETL'd 
via a multi-step (manual) process through a sequence of schemas 
(flat,core,push,meta,hard).

These are somewhat arbitrarily named, but reflect the fact that data 
moves from left to right at each step, starting in raw form in the 'flat' 
schema and eventually ending up in filtered, normalized form in the 'hard' 
schema.

From there it gets "shipped" (manually) to the gateway -- that is, an
image of the "hard" schema is dumped asa plpgsql file, sftped or otherwise 
pushed to the gateway server, and loaded from there into a fully separate
local PostgreSQL instance (where the running application resides).
From there it awaits consumption via the REST API.

In this sense, the "pipeline" and "gateway" are fully compartmentalized 
projects, in general built in complete isolation from one another and 
connecting via the manual shipping process described above.

Data Model
==========

Joining Strategy
----------------

The most important thing to know about how the various tables are 
joined (together with the responses from the NYC Geoclient) is that
they all share a composite key of two identifiers (BBL,BIN), both
unique to the NYC property data ecosystem. 

At a very basic level, the former (BBL) refers to a "tax lot",
i.e. an actual surveyed property lot (with a title and deed, and 
in any case unique ownership); while the second (BIN) refers to
a specific building (there being sometimes multiple buildings for 
a given tax lot).  Since ultimately the information this tool 
provides is per-building, a composite key on both identifiers
is needed.





