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


@timedsingle
def match_streams(pluto,acris):
    return True




