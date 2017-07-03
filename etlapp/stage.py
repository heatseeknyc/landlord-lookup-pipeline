import os
from collections import OrderedDict
from etlapp.logging import log

STAGE = 'stage'
PHASERANK = OrderedDict([('special',4),('xtracted',3),('unpack',2),('incoming',1)])

def dirpath(stage,phase,prefix):
    j = PHASERANK.get(phase)
    phasedir = "%d-%s" % (j,phase) if j is not None else phase 
    return "%s/%s/%s" % (stage,phasedir,prefix)

def filepath(stage,phase,prefix,name):
    _dirpath = dirpath(stage,phase,prefix)
    return "%s/%s.csv" % (_dirpath,name)

def mkdir_phase(stage,phase,prefix,autoviv=False):
    _dirpath = dirpath(stage,phase,prefix)
    if not os.path.exists(_dirpath):
        if autoviv:
            os.mkdir(_dirpath)
        else:
            raise ValueError("invalid state -- can't find dirpath '%s'" % _dirpath)
    return _dirpath

def mkpath(stage,phase,prefix,name,autoviv=False):
    _dirpath = mkdir_phase(stage,phase,prefix,autoviv)
    return "%s/%s.csv" % (_dirpath,name)

def export(prefix,name,stage=STAGE,autoviv=False):
    return mkpath(stage,'export',prefix,name,autoviv)

def incoming(prefix,name,stage=STAGE,autoviv=False):
    return mkpath(stage,'incoming',prefix,name,autoviv)

def latest(prefix,name,stage=STAGE):
    for phase in PHASERANK.keys():
        _filepath = filepath(stage,phase,prefix,name)
        print("%s.%s:%s -> %s" % (prefix,name,phase,_filepath))
        if os.path.exists(_filepath):
            return _filepath
    return None

