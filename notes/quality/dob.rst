Notes about data quality issues in the DOB raw files.

(June 2017)

``permit.csv``

Contains about 14 rows of '|', rather than comma-separate values.  
So we wrote a simple script:

  bin/fix-dob-permit.sh

to filter these out.

The file contains many columns with garbled fields over a small set of rows.  
These issues are described (and fixed) in the SQL code for the ``core`` schema.



