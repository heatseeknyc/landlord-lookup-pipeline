

From Scratch
------------

   [edit config/postgres.json]
   [edit /~.pgpass]
   source bin/init-env.rc
   psql -U postgres -f sql/create-database.sql 
   psql -U postgres -f sql/grant-privileges-writeuser.sql 
   bin/dopg.py -f sql/create-schema.sql
   bin/dopg.py -f sql/create-functions.sql

   etl init flat
   etl fix dob.permit
   etl fix dob.violation
   etl fix dob.contact
   etl load pluto        --  44 sec
   etl load dob          --  45 sec
   etl load hpd          --  68 sec
   etl load acris        -- 356 sec
   etl load stable       --  12 sec
   etl load misc         -- 0.5 sec

Note that it's not only quite possible, but over time, *very likely* that one or more
of the loading steps will break due to novel brokenness in the raw files, for which the
only real "fix" is to patch the loading scripts (and if it all possible, submit a pull
request).  But assumign they load we can continue thusly:
    
   etl init core 
   etl push pluto        --  47 sec
   etl push dob          -- 118 sec
   etl push hpd          -- 306 sec
   etl push acris        --  30 min 
   etl push stable       --   3 sec
   etl push misc         --   1 sec

Size-wise, the two stapes take up about 27.3G.

   etl init hard         --  70 sec + 1.2G


TODO:
 - make database creation dynamic, based on config/postgres.json



Older Stuff
-----------

Everything below here is outdate, and will be taken care of shortly.

(1) Staging

As a pre-requisite, make sure the steps in the Data Staging writeup 
have been tended to:

   notes/Data-Staging.rst

Also, make sure your environment is initialized:

  source bin/init-env.rc

(2) Create 'flat' schema, and import raw data:

  bin/dopg.py -f sql/create-schema-flat.sql
  bin/import-rawdata.sh 

(3) Run the main script which builds everything else (should take 
about 5-8 minutes).  It's also worth taking a quick look at, to understand
the other steps involved in building the pipeline:

  bin/build-pipeline.sh

(4) grant readuser priveleges

Since this step requires superuser access, it needs to be done with a 
raw shell command (as the 'dopg.py' utility is hard-wired to use the 
writeuser credentials):

   psql -U postgres -d DATABASENAME -f sql/grant-privileges-readuser.sql



TODO: provide detail

  We're now ready to export the 'hard' schema as per the steps 
  given in notes/export-database.txt.

  However, if you're running the REST gateway on the same host
  then you can also start running the daemon scrips to connect to
  these tables directly.





