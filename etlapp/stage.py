import os
from collections import OrderedDict
from etlapp.logging import log

STAGE = 'stage'
PHASERANK = OrderedDict([('special',4),('xtracted',3),('unpack',2),('incoming',1),('proto',0)])

def dirpath(phase,prefix,stage=STAGE):
    j = PHASERANK.get(phase)
    phasedir = "%d-%s" % (j,phase) if j is not None else phase
    return "%s/%s/%s" % (stage,phasedir,prefix)

def filepath(phase,prefix,name,stage=STAGE):
    _dirpath = dirpath(phase,prefix,stage)
    return "%s/%s.csv" % (_dirpath,name)

def mkdir_phase(phase,prefix,stage=STAGE,autoviv=False):
    _dirpath = dirpath(phase,prefix,stage)
    if not os.path.exists(_dirpath):
        if autoviv:
            os.mkdir(_dirpath)
        else:
            raise ValueError("invalid state -- can't find dirpath '%s'" % _dirpath)
    return _dirpath

def mkpath(phase,prefix,name,stage=STAGE,autoviv=False):
    _dirpath = mkdir_phase(phase,prefix,stage,autoviv)
    return "%s/%s.csv" % (_dirpath,name)

"""
def export(prefix,name,stage=STAGE,autoviv=False):
    return mkpath(stage,'export',prefix,name,autoviv)

def incoming(prefix,name,stage=STAGE,autoviv=False):
    return mkpath(stage,'incoming',prefix,name,autoviv)
"""


def latest(prefix,name,stage=STAGE):
    for phase in PHASERANK.keys():
        _filepath = filepath(phase,prefix,name,stage)
        # print("%s.%s:%s -> %s" % (prefix,name,phase,_filepath))
        if os.path.exists(_filepath):
            return _filepath
    return None

