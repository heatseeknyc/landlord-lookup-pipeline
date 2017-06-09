import os
from etlapp.logging import log
from etlapp.util.source import splitpath, tablename
from etlapp.util.load import make_copy_command
from etlapp.shell import dopsql
from etlapp.decorators import timedsingle
import etlapp.source
import etlapp.stage
import etlapp

def perform(posargs=None,options=None):
    log.debug("posargs=%s, options=%s" % (posargs,options))
    if len(posargs) == 1:
        return load_any(posargs[0])
    else:
        raise ValueError("invalid usage")

def load_any(srcarg,strict=True):
    if '.' in srcarg:
        prefix,name = splitpath(srcpath)
        status,delta = load_multi(prefix,[name],strict)
        return status
    else:
        prefix = srcarg
        names = etlapp.source.select(prefix,{'active':True})
        return load_multi(prefix,names,strict)

def load_multi(prefix,names,strict=True):
    """Load multiple named sourcs under a given prefix."""
    log.debug("names = %s" % names)
    for name in names:
        log.info("source %s.%s .." % (prefix,name))
        status,delta = load_source_named(prefix,name)
        _status = 'OK' if status else 'FAIL'
        log.info("source %s.%s - status = %s in %.3f sec" % (prefix,name,_status,delta))
        if strict and not status:
            return False
    return True

@timedsingle
def load_source_named(prefix,name):
    if not etlapp.source.getval(prefix,name,'active'):
        raise ValueError("source inactive by configuration")
    table = tablename('flat',prefix,name)
    log.info("table = '%s'" % table)
    infile = etlapp.stage.latest(prefix,name)
    log.info("infile = '%s'" % infile)
    assert_loadable(prefix,name,infile)
    psql = make_copy_command(table,infile)
    log.debug("psql = [%s]" % psql)
    return dopsql(psql,etlapp.pgconf)

def assert_loadable(prefix,name,infile):
    if infile is None:
        raise RuntimeError("no loadable file for prefix = '%s', name ='%s'" % (prefix,name))
    if not os.path.exists(infile):
        raise RuntimeError("can't find infile '%s'" % infile)
