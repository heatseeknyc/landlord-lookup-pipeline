This is one of 3 project repos for the HeatSeek Landlord Lookup portal, currently up and running under:

    https://lookup.heatseek.org/

This repo provides the data pipeline for the working portal -- that is, code to cleanse, extract, and load raw datasets from the NYC data ecosystem into a Postgres that the web portal can run off of (and on which some elementary analysis of the datasets can be performed).  

The basic idea is that a static image of the database can be built on one machine (e.g. perhaps your laptop) and then either shipped to another host to be deployed behind a webserver (or perhaps for analysis).  But you don't need to go through the trouble of setting up the actual web portal (or any of its dependencies) just to build the database.   

If you'd like to build or replicate the pipeline yourself, or are curious about the data 
sources used, have a look at the `Getting Started <notes/Getting-Started.rst>`_ guide.

Navigation
----------
The top-level dir (once cloned) is intended as the location from which the actual data loading scripts can be run.

- ``stage/`` is the directory where "incoming" files (i.e. downloads from external portals) first hit the ground, are unpacked and (if needed) transformed into a state where they can be loaded into the SQL database. 
- ``sql/`` contains the bulk of the database setup + internal transformation.  These are usually run with wrapper ``bin/dopg.pl``.
- ``bin/`` contain various shell wrappers (most important being ``bin/import-rawdata.sh``).
- ``extract/`` and ``shapeutil/``  provide supporting Python code (to be run with the ``-m`` flag).
- ``config/``  and ``notes/`` are self-describing.


Related Repos
-------------
The overall architecture of the portal, as such, is extremely simple.  Basically you just have a REST gateway that talks to the database, and a frontend "client" (really just an ``index.html`` page) that listens to the REST gateway.  These are available under the following repos:

- https://github.com/heatseeknyc/landlord-lookup-gateway - REST gateway
- https://github.com/heatseeknyc/landlord-lookup-client - static web portal 



