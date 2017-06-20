import os
from etlapp.logging import log
from etlapp.decorators import timedsingle
from etlapp.util.pull import make_pull_command
from etlapp.util.source import splitpath
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
        status,delta = pull_source_named(prefix,name)
        _status = 'OK' if status else 'FAIL'
        log.info("source %s.%s - status = %s in %.3f sec" % (prefix,name,_status,delta))
        if strict and not status:
            return False
    return True

@timedsingle
def pull_source_named(prefix,name):
    if not etlapp.source.getval(prefix,name,'active'):
        raise ValueError("source inactive by configuration")
    command = make_pull_command(prefix,name)
    print(command)
    return True

def assert_loadable(prefix,name,infile):
    if infile is None:
        raise RuntimeError("no loadable file for prefix = '%s', name ='%s'" % (prefix,name))
    if not os.path.exists(infile):
        raise RuntimeError("can't find infile '%s'" % infile)
