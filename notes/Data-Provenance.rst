The end result of the pipeline is a join of 3 well-known datasets in the NYC housing ecosystem.  A significant amount of filtering and scrubbed gets done along the way, but the initial provenance of each dataset is as described below.  Since the goal (at this stage) is to simply pull the raw files into the staging directory, you might want go over to that directory right now:

    cd stage


NYC Taxbill Scrapes
===================

JK's taxbill scrapes, performed aperiodically:

    curl -O http://taxbills.nyc/rawdata.csv.gz

HPD Registered Contacts
=======================

Which live under this link:

   http://www1.nyc.gov/site/hpd/about/registration-open-data.page

Note that you should pull the dataset most closely matching the date of the taxbills scrape.  The exact path may change by the time you run this, but one way or another you want to grab that file, and unpack it in the staging directory: 

   curl -O Registrations20161101.zip
   unzip Registrations20161101.zip


DHCR Rent Stablization Data 
===========================

The reults of FOIA requests, last done in 2013 -- by now a bit stale (but better than nothing):

    curl -O https://github.com/clhenrick/dhcr-rent-stabilized-data/blob/master/csv/dhcr_all_geocoded.csv

Recently I've found out about efforts to modernize the DHCR collection process, and hope to update this pipeline to make use of such efforts shortly. 




