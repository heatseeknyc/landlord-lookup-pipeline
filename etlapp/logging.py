import os
import sys
import logging

# appbase = os.path.basename(sys.argv[0])
# appname,ext = os.path.splitext(appbase)

logdir = 'log'
if not os.path.exists(logdir):
    os.mkdir(logdir)

LEVEL = {
  'info':logging.INFO,
  'debug':logging.DEBUG
}
def setlevel(logger,tag):
    """Sets the logging level on the given logging.Logger instance according to the named
    loggging level tag.  Supplied as a convenience method so we can manipulate logging levels
    without importing the 'logging' namespace into our calling application.  So instead of

        import logging
        log.setLevel(logging.INFO)

    we can just do

       etlapp.logging.setlevel(log,'debug')

    being as 'etlapp.logging' and the 'log' instance are already imported, according 
    to the standard usage pattern.
    """
    print("setlevel %s" % tag)
    level =  LEVEL.get(tag)
    if level:
        logger.setLevel(level)
    else:
        raise ValueError("unknown logging level tag [%s]" % tag)

appname = 'etl'
logging.basicConfig(
    # filename = "%s/%s-%d.log" % (logdir,appname,os.getpid()),
    stream   = sys.stdout,
    format   = "%(levelname)s %(funcName)s : %(message)s",
    level    = logging.INFO
)
log = logging.getLogger('app')

# Downgrade logging for the 'requests' package.
reqlog = logging.getLogger("requests")
if reqlog:
    reqlog.setLevel(logging.WARNING)

