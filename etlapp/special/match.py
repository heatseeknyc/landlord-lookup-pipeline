import os
from etlapp.logging import log
from etlapp.decorators import timedsingle
from etlapp.util.source import splitpath, tablename
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
    return True

