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

