#!/bin/bash -ue

# First, create a few public functions.
bin/dopg.py -f sql/create-functions.sql 

# Now let's scrub a few addresses, and build an index.
# These should take under a minute each. 
bin/dopg.py -f sql/fix-contact-addresses.sql 
bin/dopg.py -f sql/fix-registration-addresses.sql 
bin/dopg.py -f sql/create-indexes-flat.sql 

# Create the 'core', 'push', and 'meta' schemas.
bin/dopg.py -f sql/create-schema-core.sql 
bin/dopg.py -f sql/create-views-core.sql 

bin/dopg.py -f sql/create-schema-push.sql 
bin/dopg.py -f sql/create-indexes-push.sql

bin/dopg.py -f sql/create-schema-meta.sql 
bin/dopg.py -f sql/create-views-meta.sql 

# And finally, the 'hard' schema.
bin/dopg.py -f sql/create-schema-hard.sql 
bin/dopg.py -f sql/create-tables-hard.sql 
bin/dopg.py -f sql/create-indexes-hard.sql
