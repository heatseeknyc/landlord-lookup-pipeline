import os
from etlapp.logging import log
from etlapp.util.source import splitpath, tablename
from etlapp.shell import dopsql
from etlapp.decorators import timedsingle
import etlapp.source
import etlapp.stage
import etlapp

@timedsingle
def check_source_named(prefix,name):
    log.debug("source = '%s'.'%s'" % (prefix,name))
    infile = etlapp.stage.latest(prefix,name)
    return infile is not None


def perform(posargs=None,options=None):
    log.debug("posargs=%s, options=%s" % (posargs,options))
    path = uniqarg(posargs)
    return exec_any(check_source_named,path)

def exec_any(handler,srcarg,strict=True):
    if '.' in srcarg:
        srcpath = srcarg
        prefix,name = splitpath(srcpath)
        return exec_multi(handler,prefix,[name],strict)
    else:
        prefix = srcarg
        names = etlapp.source.select(prefix,{'active':True})
        return exec_multi(handler,prefix,names,strict)

def exec_multi(handler,prefix,names,strict=True):
    """Do something for multiple named sourcs under a given prefix."""
    log.debug("names = %s" % names)
    for name in names:
        log.info("source %s.%s .." % (prefix,name))
        status,delta = handler(prefix,name)
        _status = 'OK' if status else 'FAIL'
        log.info("source %s.%s - status = %s in %.3f sec" % (prefix,name,_status,delta))
        if strict and not status:
            return False
    return True

def uniqarg(posargs):
    if posargs and len(posargs) == 1:
        return posargs[0]
    raise ValueError("invalid usage (too many positional arguments)")
