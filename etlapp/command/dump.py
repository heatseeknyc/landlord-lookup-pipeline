import os
from etlapp.logging import log
from etlapp.decorators import timedsingle
from etlapp.util.source import splitpath, tablename
from etlapp.util.dump import make_dump_command
from etlapp.shell import dopsql
import etlapp.source
import etlapp.stage
import etlapp

def perform(posargs=None,options=None):
    log.debug("posargs=%s, options=%s" % (posargs,options))
    if len(posargs) == 1:
        return exec_any(posargs[0])
    else:
        raise ValueError("invalid usage")

def exec_any(srcarg,strict=True):
    if '.' in srcarg:
        srcpath = srcarg
        prefix,name = splitpath(srcpath)
        return exec_multi(prefix,[name],strict)
    else:
        prefix = srcarg
        names = etlapp.source.select(prefix,{'active':True})
        return exec_multi(prefix,names,strict)

def exec_multi(prefix,names,strict=True):
    """Load multiple named sourcs under a given prefix."""
    log.debug("names = %s" % names)
    for name in names:
        log.info("source %s.%s .." % (prefix,name))
        status,delta = dump_source_named(prefix,name)
        _status = 'OK' if status else 'FAIL'
        log.info("source %s.%s - status = %s in %.3f sec" % (prefix,name,_status,delta))
        if strict and not status:
            return False
    return True

@timedsingle
def dump_source_named(prefix,name,force=False):
    # if not etlapp.source.exists(prefix):
    #    raise ValueError("unrecognized source group '%s'")
    # XXX at this point, we should be checking for relation existence as well.
    table = tablename('norm',prefix,name)
    log.info("table = '%s'" % table)
    outfile = etlapp.stage.mkpath('export',prefix,name,autoviv=True)
    log.info("outfile = '%s'" % outfile)
    if not force and os.path.exists(outfile):
        message = "cowardly refusing to overwrite existing outfile '%s' without --force option"
        raise ValueError(message % outfile)
    psql = make_dump_command(table,outfile)
    log.debug("psql = [%s]" % psql)
    return dopsql(psql,etlapp.pgconf)

    command = make_dump_command(prefix,name)
    print(command)
    return True

def assert_loadable(prefix,name,infile):
    if infile is None:
        raise RuntimeError("no loadable file for prefix = '%s', name ='%s'" % (prefix,name))
    if not os.path.exists(infile):
        raise RuntimeError("can't find infile '%s'" % infile)
