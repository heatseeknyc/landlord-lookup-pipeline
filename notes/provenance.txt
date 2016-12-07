The end result of the pipeline is a join of 3 well-known datasets in the NYC housing ecosystem.  A significant amount of filtering and scrubbed gets done along the way, but the initial provenance of each dataset is as follows: 


NYC Taxbill Scrapes
===================

JK's taxbill scrapes, performed aperiodically:

    http://taxbills.nyc/rawdata.csv.gz


HPD Registered Contacts
=======================

Which live under this link:

   http://www1.nyc.gov/site/hpd/about/registration-open-data.page

Note that you should pull the dataset most closely matching the date of the taxbills scrape.


DHCR Rent Stablization Data 
===========================

The reults of FOIA requests, last done in 2013 -- by now a bit stale (but better than nothing):

    https://github.com/clhenrick/dhcr-rent-stabilized-data/blob/master/csv/dhcr_all_geocoded.csv

Recently I've found out about efforts to modernize the DHCR collection process, and hope to update this pipeline to make use of such efforts shortly. 




