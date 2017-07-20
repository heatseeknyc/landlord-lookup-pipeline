from collections import OrderedDict
from copy import deepcopy
import yaml

DEFAULTS = {'active':True}

def splitpath(srcpath):
    if isinstance(srcpath,str):
        terms = srcpath.split('.')
        if len(terms) == 1:
            return terms[0],None
        if len(terms) == 2:
            return tuple(terms)
    raise ValueError("invalid source path [%s]" % srcpath)

def _load_config_recs(path):
    with open(path,"rtU") as f:
        return yaml.load(f)

def augment(r,d):
    """Creats a new dict which is a deepcopy of r, overlayed with values from d."""
    rr = deepcopy(r)
    for k,v in d.items():
        if k not in rr:
            rr[k] = deepcopy(v)
    return rr

def load_config_recs(path):
    recs = _load_config_recs(path)
    return [augment(r,DEFAULTS) for r in recs]

def recs2dict(recs):
    d = OrderedDict()
    for r in recs:
        name = r['name']
        del r['name']
        if name in d:
            raise ValueError("invalid configuration - duplicated source name '%s' detected" % name)
        d[name] = deepcopy(r)
    return d

def loadcfg_source(path):
    recs = load_config_recs(path)
    return recs2dict(recs)

def tablename(schema,prefix,name):
    name = name.replace('-','_').replace('.','_')
    return "%s.%s_%s" % (schema,prefix,name)

def source2prefix(srcpath):
    terms = srcpath.split('.')
    if len(terms) > 1:
        return terms[0]
    raise ValueError("invalid source path [%s]" % srcpath)

