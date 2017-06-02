import os

STAGE = 'stage'

def mkpath_incoming(prefix,name,stage=STAGE):
    return "%s/incoming/%s/%s.csv" % (stage,prefix,name)

def mkpath_xtracted(prefix,name,stage=STAGE):
    return "%s/xtracted/%s/%s.csv" % (stage,prefix,name)

def latest(prefix,name,stage=STAGE):
    _incoming = mkpath_incoming(prefix,name,stage)
    _xtracted = mkpath_xtracted(prefix,name,stage)
    return \
        _xtracted if os.path.exists(_xtracted) else \
        _incoming if os.path.exists(_incoming) else \
        None



