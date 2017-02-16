This is one of 3 project repos for the HeatSeek Landlord Lookup portal, currently up and running under:

    https://lookup.heatseek.org/

This repo provides the data pipeline for the working portal -- that is, code to cleanse, extract, and load raw datasets from the NYC data ecosystem into a Postgres that the web portal can run off of (and on which some elementary analysis of the datasets can be performed).  

The basic idea is that a static image of the database can be built on one machine (e.g. perhaps your laptop) and then either shipped to another host to be deployed behind a webserver (or perhaps for analysis).  But you don't need to go through the trouble of setting up the actual web portal (or any of its dependencies) just to build the database.   

If you'd like to build or replicate the pipeline yourself, or are curious about the data 
sources used, have a look at the `Getting Started <notes/Getting-Started.rst>`_ guide.

Related Repos
-------------




