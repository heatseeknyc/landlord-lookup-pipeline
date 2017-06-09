import os
from etlapp.logging import log
from etlapp.util.source import splitpath, tablename
from etlapp.util.load import make_copy_command
from etlapp.shell import dopsql
import etlapp.source
import etlapp.stage
import etlapp

def perform(posargs=None,options=None):
    log.debug("posargs=%s, options=%s" % (posargs,options))
    if len(posargs) == 1:
        return load_source_named(posargs[0])
    else:
        raise ValueError("invalid usage")

def load_source_named(srcpath):
    prefix,name = splitpath(srcpath)
    if not etlapp.source.getval(prefix,name,'active'):
        raise ValueError("source inactive by configuration")
    table = tablename('flat',prefix,name)
    log.info("table = '%s'" % table)
    infile = etlapp.stage.latest(prefix,name)
    log.info("infile = '%s'" % infile)
    assert_loadable(srcpath,infile)
    psql = make_copy_command(table,infile)
    log.debug("psql = [%s]" % psql)
    return dopsql(psql,etlapp.pgconf)

def assert_loadable(srcpath,infile):
    if infile is None:
        raise RuntimeError("no loadable file for source = '%s'" % srcpath)
    if not os.path.exists(infile):
        raise RuntimeError("can't find infile '%s'" % infile)
