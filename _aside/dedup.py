#
# A simple plaintext line deduper.
# 
# We can't just use 'uniq' because the duplicates generally aren't 
# contiguous in our file of interest; and 'sort|uniq' wouldn't preserve
# the header (and though it isn't required, we'd prefer not to disturb 
# order of first occurence for the rest of the file, either).
#
# Finally, we do an rstrip() to remove any trailing whitespace that
# might be masking duplicates; and normalize the EOLN character to  
# the system default.
#

import sys

seen = set()
for line in sys.stdin:
    line = line.rstrip();
    if line not in seen:
        seen.add(line)
        print(line)


