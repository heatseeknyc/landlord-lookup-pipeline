"""
OK, so it's not really a test - more like a demo.
Being as it's hard to construct unit tests when a real, populated staging
directory is need to do meaningful tests on.

But at least it's something.
"""
from tabulate import tabulate
from collections import OrderedDict
import etlapp.stage as stage
import etlapp.source as source

"""
The names for these methods are kind of loosey-goosey.
But hey, it's just a test suite.
"""

def datafor(prefix,name):
    """Provides the "data for" the given pair of (:prefix,:name)."""
    active = source.getval(prefix,name,'active')
    path = stage.latest(prefix,name)
    return active,path

def resolve(prefix):
    """
    Resolves a prefix into an OrderedDict of (name,values), where :values is
    a tuple of values of interest.
    """
    names = source.names(prefix)
    print("names[%s] = %s" % (prefix,names))
    pairs = ((name,datafor(prefix,name)) for name in names)
    return OrderedDict(pairs)

def construct(sources):
    """Construct our big nested struct from a sequence of prefixes.
    Reutrns: a nifty OrderdDict-of-OrderedDict-of-sequence struct."""
    pairs = ((prefix,resolve(prefix)) for prefix in sources)
    return OrderedDict(pairs)

def rollout(d):
    """Rolls out a bilevel OrderdDict-of-OrderedDict-of-sequence struct in the natural way."""
    for k,dd in d.items():
        for kk,vv in dd.items():
            yield tuple([k,kk] + list(vv))

def main():
    sources = source.prefixes()
    print("sources = ",sources)
    d = construct(sources)
    rows = list(rollout(d))
    print(tabulate(rows))


if __name__ == '__main__':
    main()

