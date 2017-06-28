import os
from etlapp.logging import log

STAGE = 'stage'

def mkdir_branch(stage,branch,prefix,autoviv=False):
    dirpath = "%s/%s/%s" % (stage,branch,prefix)
    if not os.path.exists(dirpath):
        if autoviv:
            os.mkdir(dirpath)
        else:
            raise ValueError("invalid state -- can't find dirpath '%s'" % dirpath)
    return dirpath

def mkpath(stage,branch,prefix,name,autoviv=False):
    dirpath = mkdir_branch(stage,branch,prefix,autoviv)
    return "%s/%s.csv" % (dirpath,name)

def export(prefix,name,stage=STAGE,autoviv=False):
    return mkpath(stage,'export',prefix,name,autoviv)

def incoming(prefix,name,stage=STAGE,autoviv=False):
    return mkpath(stage,'incoming',prefix,name,autoviv)

_phases = ('xtracted','unpack','incoming')
def latest(prefix,name,stage=STAGE):
    n = len(_phases)
    for j,phase in enumerate(_phases):
        phasedir = "%d-%s" % (n-j,phase)
        filepath = mkpath(stage,phasedir,prefix,name)
        if os.path.exists(filepath):
            return filepath
    return None

"""
    _xtracted = mkpath(stage,'xtracted',prefix,name,stage)
    log.debug("_incoming = '%s'" % _incoming)
    log.debug("_xtracted = '%s'" % _xtracted)
    return \
        _xtracted if os.path.exists(_xtracted) else \
        _incoming if os.path.exists(_incoming) else \
        None
"""

