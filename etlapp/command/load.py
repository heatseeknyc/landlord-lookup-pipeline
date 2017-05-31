import os
import sys
from etlapp.logging import log
from etlapp.util.source import splitpath, tablename
from etlapp.util.load import make_copy_command
from etlapp.shell import invoke, dopsql
import etlapp.source
import etlapp.stage
import etlapp

def perform(posargs=None,options=None):
    log.debug("posargs=%s, options=%s" % (posargs,options))
    if len(posargs) == 1:
        return loadsource(posargs[0])
    else:
        raise ValueError("invalid usage")


def loadsource(srcpath):
    prefix,name = splitpath(srcpath)
    config = etlapp.source.getcfg(prefix)
    log.debug("config = %s" % config)
    d = config.get(name)
    if d is None:
        log.error("invalid source name")
        return False
    log.debug("d = %s" % d)
    if not d['active']:
        log.error("source inactive by configuration")
        return False
    table = tablename('flat',prefix,name)
    log.info("table = '%s'" % table)
    infile = etlapp.stage.incoming(prefix,name)
    log.info("infile = '%s'" % infile)
    if not os.path.exists(infile):
        log.error("can't find infile '%s'" % infile)
        return False
    psql = make_copy_command(table,infile)
    log.info("psql = [%s]" % psql)
    return dopsql(psql,etlapp.pgconf)


