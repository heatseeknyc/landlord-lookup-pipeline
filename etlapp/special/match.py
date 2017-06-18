import os
from etlapp.logging import log
from etlapp.decorators import timedsingle
from etlapp.util.source import splitpath, tablename
from etlapp.util.io import read_recs
from etlapp.shell import dopsql
import etlapp.source
import etlapp.stage
import etlapp

def perform(posargs=None,options=None):
    log.debug("posargs=%s, options=%s" % (posargs,options))
    if len(posargs) == 0:
        return matchup()
    else:
        raise ValueError("invalid usage")

def matchup():
    infile_acris = etlapp.stage.export('acris','condo-maybe')
    infile_pluto = etlapp.stage.export('pluto','condo-primary')
    log.info("..")
    if not os.path.exists(infile_acris):
        raise ValueError("can't find infile '%s'" % infile_acris)
    if not os.path.exists(infile_pluto):
        raise ValueError("can't find infile '%s'" % infile_acris)
    log.info("files ok!")
    acris = read_recs(infile_acris)
    pluto = read_recs(infile_pluto)
    status,delta = match_streams(pluto,acris)
    _status = 'OK' if status else 'FAIL'
    log.info("status = %s in %.3f sec" % (_status,delta))
    log.info("done")
    return True

"""
A quick hack to impose integer types on selected columns.
We'd prefer something more robust and flexible, but for now this is much preferable
to loading some large framework (e.g. pandas) to do this for us.
"""
def castint(r,keys):
    """
    Casts dict values (corresponding to the given sequence) to int, in-place.
    We also return the dict struct as a convenience for generator-type expressions.
    """
    for k in keys:
        if k in r:
            v = r[k]
            if v is not None:
                r[k] = int(v)
    return r


_intcols = (
    'bbl',
    'units_total','units_res','bldg_count','num_bldgs','year_built', # pluto columns
    'history_count','lot_max','condo_depth','docid_count'            # acris columns
 )
def loadstreams(_pluto,_acris):
    """
    A simple idiom to load the two respective streams of interest.
    Note that it assumed that sufficient checking of pre-conditions has been done by this,
    hence there's basically no error handling at this stage.
    """
    def cast(r):
        return castint(r,_intcols)
    count = {}
    pluto = list(cast(r) for r in _pluto)
    log.debug("slurp pluto ..")
    count['pluto'] = len(pluto)
    log.debug("slurp acris..")
    acris = list(cast(r) for r in _acris)
    count['acris'] = len(acris)
    return pluto,acris,count

@timedsingle
def match_streams(_pluto,_acris):
    pluto,acris,count = loadstreams(_pluto,_acris)
    log.info("count = %s" % count)
    print(pluto[0])
    print(acris[0])
    return True




