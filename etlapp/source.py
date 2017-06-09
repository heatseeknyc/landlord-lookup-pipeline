from etlapp.util.source import loadcfg_source
from etlapp.logging import log

ROOT = 'source'
CONFIG = {}

def configpath(prefix):
    return "%s/%s.yaml" % (ROOT,prefix)

def loadcfg(prefix):
    path = configpath(prefix)
    CONFIG[prefix] = loadcfg_source(path)
    return CONFIG[prefix]

def getcfg(prefix):
    config = CONFIG.get(prefix)
    return config if config else loadcfg(prefix)

def getcfg_source(prefix,name):
    """Shorthand to get the config dict for a named source.  If not present,
    a ValueError is raised."""
    config = getcfg(prefix)
    if name in config:
        return config[name]
    else:
        raise ValueError("invalid source name '%s' for prefix '%s'" % (name,prefix))

def getval(prefix,name,attr):
    """Shorthand to fetch an attribute value by source name.  The attribute need not
    be present, but the named source must be."""
    d = getcfg_source(prefix,name)
    log.debug("config[%s] = %s" % (name,d))
    return d.get(attr)


# In the future we may wish to allow the values in the query dict to be callables or regexes.
def matches(d,query):
    """
    Determines whether the given dict "matches" the given query.  At present this
    is taken to mean "have the same keys, and values match via the 'is' operator."
    """
    for k,v in query.items():
        if k not in d:
            return False
        if d[k] is not query[k]:
            return False
    return True

def select(prefix,query):
    """Given a source prefix, returns the names which match the given query
    (according to the match function in this module)."""
    config = getcfg(prefix)
    return list(k for k,v in config.items() if matches(v,query))

