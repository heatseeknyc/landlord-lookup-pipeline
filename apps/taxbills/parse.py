import random
from itertools import islice
import resource

def consume(recs,limit=None,stride=1000000):
    """
    Given an record stream, magically constructs a dict-of-dict struct
    (which we'll call a "table") representing, for each BBL, the latest
    active date and corresponding owner/address fields for that date.
    """
    total = 0
    active,owner,address = {},{},{}
    for i,x in enumerate(islice(recs,limit)):
        k = x['bbl']
        curdate = x['activitythrough']
        if k not in active or curdate > active[k]:
            active[k] = curdate
            owner[k] = None
            address[k] = None
        if curdate == active[k]:
            if x['key'] == 'Owner name':
                owner[k] = x['value']
            if x['key'] == 'Mailing address':
                address[k] = x['value']
        if i % stride == 0 and i > 0:
            size = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss / 1000
            print("step %d: keys = %d, size = %s" % (i,len(active),size))
        total += 1
    return {'active':active,'owner':owner,'address':address,'total':total}

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


