This is one of 3 project repos for the HeatSeek Landlord Lookup portal, currently up and running under:

    https://lookup.heatseek.org/

This repo provides the data pipeline for the working portal -- that is, code to cleanse, extract, and load raw datasets from the NYC data ecosystem into a PostgreSQL database that the web portal can run off of (and on which some elementary analysis of the datasets can be performed).  

The basic idea is that a static image of the database can be built on one machine (e.g. perhaps your laptop) and then either shipped to another host to be deployed behind a webserver (or perhaps for analysis).  But you don't need to go through the trouble of setting up the actual web portal (or any of its dependencies) just to build the database -- and conversely, you can (is you know SQL, and don't mind working with Postgres) use the backend database for analytics, without messing with the frontend portal. 

If you'd like to build or replicate the pipeline yourself, or are curious about the data 
sources used, have a look at the `Getting Started <notes/Getting-Started.rst>`_ guide.

Sources
-------

The current portal is an aggregation of some 25+ datasets from the NYC data ecosystem, some well-know, others not so well-known.  We'd like to do a better job at describing these, but in "order of appearance", is it were, the casting call goes like this: 

- PAD v17b + Pluto 16v2
- ACRIS (master, legal, parties)
- DOB/ECB (complaints, violations)
- HPD (registration, complaints, violations, special programs)
- Quaterly DOF taxbill scrapes provided by John Krauss (http://taxbills.nyc/)
- DHCR rent stabilization list (2015) 
- Various other datasets from DCP, DCAS, LPC, etc. 

Currently the portal updates monthly, around the time the monthly-updating datasets (ACRIS, DOB, HPD) get released (typically between the 10th and 15th of the month).  Other datasets (like PAD, Pluto, DCP zoning, and the rent stabilization lists) are released much more irregularly, and incorporate those updates as they become available. 


What you'll find here
---------------------

There isn't much in the way of documentation (that would be useful to outsiders), at present.  But just to provide a quick overview of what's in here, the top-level dir -- which, once cloned, is intended as the location from which the actual data loading scripts can be run -- looks about like this:

- ``stage/`` is the directory where raw incoming files (i.e. downloads from external portals) first hit the ground, are unpacked and (if needed) transformed into a state where they can be loaded into the SQL database.  We call this process "stating", and it's described in the `Data Stating <notes/Data-Staging.rst>`_ note. 
- ``sql/`` contains the bulk of the database setup + internal transformation.  These are usually run with wrapper ``bin/dopg.pl``.
- ``etlapp/`` is the ETL framework as such.  Provides a simple CLI for automating most of the steps in the ETL process.  Still in early stages of development. 
- ``source/`` - configuration files for data sources 
- ``bin/`` contains a few important shell commands (``etl``, ``dopg``) and various maintenance scripts. 
- ``config/`` - postgres-specific configuration. 
- ``notes/`` - further documentation. 
- ``extract/`` and ``shapeutil/``  are some earlier versions of the extraction-specific code (for shapefiles, etc).  


Related Repos
-------------
The overall architecture of the portal, as such, is extremely simple.  Basically you just have a REST gateway that talks to the database, and a frontend "client" (really just an ``index.html`` page) that listens to the REST gateway.  These are available under the following repos:

- https://github.com/heatseeknyc/landlord-lookup-gateway - REST gateway
- https://github.com/heatseeknyc/landlord-lookup-client - static web portal 



