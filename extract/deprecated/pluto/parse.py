"""
In which we perform some simple extraction / normalization in records
in the raw PLUTO csv files.  Applies to Pluto 16v2.

(As of Feb 2017, no longer in use, because we aren't using this branch
of the PLUTO dataset).
"""

import re

"""
  We include a reduced (but otherwise verbatim) sample record as
  a way of indicating fields of initial interest.  Obviously we won't
  be making any use of the values in this dict, but we leave them
  in-place as they serve as a form of documentation.

  Note that we'll be making some adjustments on some of these fields
  (most importantly, the BBL field) and introducing at least one new
  field (the "ZoneSig", or Zone Signature, built from the other 5 zoning
  information fields.
"""

sample = {
    "BBL": "1000010010.00",
    "Address": "1 GOVERNORS ISLAND",
    "AssessLand": "104445450.00",
    "AssessTot": "156510900.00",
    "BldgClass": "Y4",
    "BldgArea": "2725731",
    "CD": "101",
    "CondoNo": "0",
    "HistDist": "Governors Island Historic District",
    "LandUse": "08",
    "Landmark": "CASTLE WILLIAMS",
    "NumBldgs": "158",
    "NumFloors": "0.00",
    "OwnerName": "GOVERNORS ISLAND CORP",
    "OwnerType": "P",
    "PLUTOMapID": "1",
    "UnitsRes": "0",
    "UnitsTotal": "0",
    "YearBuilt": "1900",
    "ZoneDist1": "R3-2",
    "ZoneDist2": "",
    "ZoneDist3": "",
    "ZoneDist4": "",
    "ZoneMap": "16a"
}

"""
Creates a specially sorted list of field keys (which will also be
the order they're presented in the first-pass output CSV).  The ordering 
is very simple: since the BBL is our primary key, it goes out in front;
all other fields are in lexical order.
"""
keyset = set(list(sample.keys()))
keyset.remove('BBL')
fields = tuple(["BBL"] + sorted(keyset))


def normalize(r):
    r = {k:r[k] for k in fields}
    bbl_raw = r.pop('BBL')
    bbl_canon = canonbbl(bbl_raw)
    if bbl_canon is None:
        raise ValueError("invalid BBL: '%s'" % bbl_raw)
    r['BBL'] = bbl_canon
    r['Address'] = r['Address'].strip()
    return r

"""
Note that because the BBL field is quite special (and we want to be sure 
that it always appears in a certain expected structure), we prefer to do  
a regex capture (rather than say a float/int cast, which can fail to detect 
degenerate input cases, if not done properly). 
"""
bblpat = re.compile('^(\d{10})(?:(\.\d{2})*)$')
def canonbbl(s):
    """
    Given a BBL field as it appears in a raw input file, returns the canonicalized
    (integer) value if valid, or None otherwise.  Note that in Pluto 16v2, BBLs are
    usually of the form "1000010010.00", but sometimes "3000010001"; so our regex
    is designed to capture both cases.
    """
    m = re.match(bblpat,s)
    if m:
        return int(m.group(1))
    else:
        return None

