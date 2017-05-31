import sys
import simplejson as json
from subprocess import call
from etlapp.logging import log

def perform(posargs=None,options=None):
    log.info("posargs=%s, options=%s" % (posargs,options))

