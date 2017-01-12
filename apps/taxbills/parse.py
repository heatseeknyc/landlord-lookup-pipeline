import random
from itertools import islice

def consume(recs,limit=None):
    """
    Given an record stream, magically constructs a dict-of-dict struct
    (which we'll call a "table") representing, for each BBL, the latest
    active date and corresponding owner/address fields for that date.
    """
    active,owner,address = {},{},{}
    for x in islice(recs,limit):
        k = x['bbl']
        curdate = x['activitythrough']
        if k not in active or curdate > active[k]:
            active[k] = curdate
            owner[k] = None
            address[k] = None
        if curdate == active[k]:
            if x['key'] == 'owner name':
                owner[k] = x['value']
            if x['key'] == 'mailing address':
                address[k] = x['value']
    return {'active':active,'owner':owner,'address':address}

def genrecs(t,reverse=False):
    """
    Given the "table" struct defined above, emits a normalized record stream.
    """
    for k in sorted(t['active'].keys(),reverse=reverse):
        yield {
            'bbl':k,
            'active_date': t['active'][k],
            'owner_name': t['owner'][k],
            'mailing_address': t['address'][k],
        }

#
# deprecated
#
def corrupt(t,q):
    """Corrupts a table struct by setting fields to None, randomly selected
    according to the given probability q.  Used in the past for troubleshooting,
    specifically to generate degenerate records that don't normally -- but might --
    occur in live datasets."""
    for k in t['active']:
        if random.random() < q:
            t['owner'][k] = None
        if random.random() < q:
            t['address'][k] = None


