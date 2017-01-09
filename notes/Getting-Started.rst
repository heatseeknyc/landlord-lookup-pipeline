
How to start building the pipeline from scratch.

Assumptions
===========

Platform-wise, at a bare minimum you'll need to have: 
 - a Unix-like host (we use OS X in development, and CentOS in production) 
 - a modern-ish version of PostgreSQL (we use 9.5.2), hereinafter referred to simply as "Postgres".
 - Python 3.5

You should also some basic administration skills in Postgres (or the ability to school yourself in the subject fairly quickly), and access to the superuser account on the Postgres instance you'll be using. 

Note that (big-picture) setup steps as such are presented as a sequence of written instructions (rather than scripts).  They're tailored for the production environment (CentOS), with in some cases parallel versions presented for OSX-specific tweaks; if you're using something else, it's assumed you have the ability to generalize, and adjust your installation steps accordingly.  

In any case all work will be performed from the top-level directory of the location to where this repo was unpacked (i.e. the directory just above this one, if you've just unpacked the repo and are looking at this note as a regular text file).  

Finally, by this point you should take a look at the Data-Provenance.rst note, which describes the raw datasets we build from, and their current (external) locations.  It will be used in the next step. 

Data Staging
============

See the note on Data-Staging.rst, and follow the instructions.


Postgres Setup
==============


Running the Pipeline
====================



