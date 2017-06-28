import re
import sys

"""
A list of regex patterns for lines observed to have caused severe indigestion in the
postgres COPY command, apparently due to gratuitous embedded commas.

By convention we list the first few columns (if reasonably possible) to provide
better visual context if you need to track these down in the raw files.
"""

badness = [
    # garbled violation number line 644496 - June 2017
    '^153327,34132163K,RESOLVE,112295C07M0,VW,',
]
badpat = [re.compile(_) for _ in badness]

def is_bad(line):
    for pat in badpat:
        if re.match(pat,line):
            return True
    return False

inpath = sys.argv[1]
outpath = sys.argv[2]

infile  = open(inpath,"rtU")
outfile = open(outpath,"wt")

skipped,passed = 0,0
for line in infile:
    if is_bad(line):
        skipped += 1
    else:
        passed += 1
        outfile.write(line)

print("passed %d, skipped %d" % (passed,skipped))


