This note describes both the current *provenance* of the external data sets we'll be importing, and the (current) exact steps to acquire them and position them in a suitable location so they can be acted on the pipeline.  

Though the *acquisition* process could be automated, it's simpler all around to just perform these steps manually -- both because the downloading proceess is necessarily a bit slow, and because it's the one part of the pipeline process that's intrinsically subject to "breakage" from the outside (being as the external locations for these files -- or even their very existance -- can change at any time, for reasons beyond our control). 

At any rate, one way or another, the end of this phase is simply to have the source files all present and accounted for in the ``incoming`` directory, i.e.::

  ls stage/incoming/
  stage/incoming/Building Footprints.zip
  stage/incoming/Registrations20161101.zip
  stage/incoming/dhcr_all_geocoded.csv
  stage/incoming/nyc_pluto_16v2%20.zip
  stage/incoming/rawdata-2016-june.csv.gz

Along with a set of canonical alises (described in the *Canonicalization* section below).

Synchronization
---------------

Before proceeding, you need to think about which "point-in-time" (PIT) you're attempting to model the state of the NYC property ecosystem for, and make sure that the datasets you're fetching are at least roughly in synch with each other.  In that vein, note that it's greatly preferable to have the raw datasets perhaps *a bit behind, but more closely in synch* than the converse (some very fresh, but others lagging greatly behind).  

Keep in mind that there's something like an 8% transfer churn in the NYC real estate market annually; so a gap of 3 months between your freshest and most stale datasets means that you can expect around 2% of your joined record sets (per BBL) will be out of whack -- which is quite high as an error rate, actually.  That said, there's an intrinsic noise level in these datsets already -- particulary as regards current ownership;
 probably at least 1-2 percent -- due simply to latency in reporting, and the nature of the city's IT operations.  But he point is you want to at least to try to keep the datasets as closely aligned as possible (ideally within 1-2 months of each other, and no more than 3 months "out of step").

For example, even though (at current writing) we're in February of 2017, the PIT we're roughly aiming for is Q3 2016.  That's (roughly) in line with the fact that our latest taxbill scrape is from June 2016.  Our HPD Registrations happen to be from October of 2016 -- i.e. a four month reporting gap.  Which is not great, but given that the portal is currently in the proof-of-concept stage, fine enough for now.

Downloading
===========

Having identified the PIT you're aiming for, we can proceed to manually fetch the versioned datasets of interests. 

The action to actually get the file is presented as a ``curl`` command for each dataset of interest (which would of course need to be modified for whatever version you're fetching).  To be clear, it's up to you whether you use ``curl`` (or some other tool to your liking), or grab it manually using your browser.  Either way, the idea is that they should end up in the ``incoming`` directory, because that's where they'll get referenced by subsequent steps.  

That said, note that ``curl`` command is conveniently constructed in such a way (using the ``-O`` flag) such that the target file will end up as a file named exactly as it appears in the URL, in the location where you're running the command from.  Since end goal is to have the files appear in the ``incoming`` directory, you might as well go there now:: 

  cd stage/incoming

1. Taxbill Scrapes
------------------

As of June 2016 these should be available under versioned names, e.g.::

  curl -O http://taxbills.nyc/rawdata-june-2016.csv.gz


2. HPD Registered Contacts 
--------------------------

These are currently presented as a ``zip`` archive containing two datasets (for registrations and contacts; along with an XML file we don't need).  At present writing, they live under this URL::

  http://www1.nyc.gov/site/hpd/about/registration-open-data.page

Note that you should pull the dataset most closely matching the date of the taxbills scrape.  The exact path may change by the time you run this, but one way or another you want to grab that file, and unpack it in the staging directory::

  curl -O http://www1.nyc.gov/assets/hpd/downloads/misc/Registrations20161101.zip

BTW note that the date in the zip file will likely be in the early part of the "next month" after the effective date we're aiming for (as listed on the HPD cover page above).  So in this case, even though we're aiming for the "(end of) October 2016" snapshot, the date on the file reads ``20160111``.


3. MAPPluto 
-----------

Currently, the MAPPluto files live here::

    http://www1.nyc.gov/site/planning/data-maps/open-data/dwn-pluto-mappluto.page

Sample direct link::

    http://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/bk_mappluto_16v2.zip

One way or another, you'll want to end up with these files in place::

  stage/incoming/pluto/bk_mappluto_16v2.zip
  stage/incoming/pluto/bx_mappluto_16v2.zip
  stage/incoming/pluto/mn_mappluto_16v2.zip
  stage/incoming/pluto/qn_mappluto_16v2.zip
  stage/incoming/pluto/si_mappluto_16v2.zip


4. Building Footprints 
----------------------

TODO: describe fetch for this source. 


5. DHCR Stabilization Lists 
---------------------------

The results of FOIA requests, last done in 2015 -- by now a bit stale (but better than nothing).  Here's the top-level location for these files:
  
  https://github.com/clhenrick/dhcr-rent-stabilized-data/tree/master/csv

Because the raw file is somewhat big, GitHub creates a special location for it, which has changed over time.  At present, it can be fetched thusly:: 

   curl -O https://raw.githubusercontent.com/clhenrick/dhcr-rent-stabilized-data/master/csv/dhcr_all_geocoded.csv

Canonicalization
================

Before moving on to the *extraction* phase, we perform a one last crucial manual step in which we create canonical aliases for the peculiarly named external files::
 
  ln -s rawdata-2016-june.csv.gz rawdata.csv.gz
  ln -s Registrations20161101.zip registrations.zip
  ln -s nyc_pluto_16v2%20.zip pluto.zip
  ln -s 'Building Footprints.zip' buildings.zip

This will allow our scripts in the subsequent extraction phase to automatically "pick up" these files without having to either hard-code for (or come up with weird hacks to find) the raw archive files based on whatever weird name they have at the moment. 

Note that at present there's no alias created for the DHCR file -- it's already pretty generic as it is, and (because that version is the last we'll probably be using from that particular external project), it's unlikely to change in the future.  


Make a Snapshot
===============

After going through the trouble of manually fetching these datasets, it'd be useful to create and publish a snapshot of the 5 files bundled together, so that people can reconstruct your pipeline for your PIT without going through all that trouble (which can only become more troublesome over time, if not perhaps impossible, given the inevitability that the source locations for these datasets will change over time). 

So we simply create a ``zip`` archive:  Note that timestamp should of coures reflect the logical PIT you're aiming to represent, rather than the current calendar date.  So in this example, we might use the date ``20161031``, e.g.::

   cd stage
   zip -r --symlinks pipeline-incoming-YYYYMMDD.zip incoming

And then make it available "somewhere".  At current writing there's no system in place for this, but as the project evolves we'll probably be using a common data portal of some sort, so that people can find snapshots like these without too much difficulty. 


