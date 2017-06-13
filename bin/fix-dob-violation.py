import re
import sys

"""
A list of regex patterns for lines observed to have caused severe indigestion in the
postgres COPY command.  Which in (apparently) all cases is due to the presence of garbled
columns containing unquoted commas, e.g. "ES,)@", while the overall comman count remains
the same (which has the effect of -misordering- the remaining columns, rather than
triggering a constraint on column length).

Fix is to simply drop the offending lines, based on patterns identified and captured
each time an offending line as encountered.  Preferably these will be of the form

    "^<first-few-columns>.*,<street-pattern>"

On the theory that the <first-few-columns>, which include the Violation ID,  will identify
such lines uniquely, while having the <street-pattern> in there also will be helpful to
align the patterns with the emited by the COPY command, e.g.

     ERROR:  value too long for type character(8)
     CONTEXT:  COPY dob_violation, line 139391, column disposition_date: "WASHINGTON PLACE"

But in some case we got lazy and just put down other patterns (which might unforunately
match too many lines), because that's what we came up with first.
"""

badness = [
    '^228391,1,1010218,.*,WASHINGTON PLACE',
    '^125722,2,2003053,.*,JEROME AVENUE',
    '^263321,1,1043360,.*,EAST.*59.STREET',
    '^423349,1,1038929,.*,EAST.*49.STREET',
    '^688184,1,1023740,.*,WEST.*58.STREET',
    '651698,.*HARRISON.AVE',
    '579004.*LAGUARDIA.PLACE',
    '50078.*BARCLAY.AVENUE',
    '717480.*55.STREET',
    '^1986224,',
    '^1921459,',
    '^100314,1,1',
    '^1921460,.,1',
    '^703245,3,3',
    '^98699,1,1001',
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


