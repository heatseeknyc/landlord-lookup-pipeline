import sys
import argparse
import etlapp.command
import etlapp.util.io as io
from etlapp.logging import log
from etlapp.util.argparse import splitargv
from etlapp.decorators import timedsingle


etlapp.pgconf = io.slurp_json("config/postgres.json")
TRACE = False # for noisy exception tracing

USAGE = """etl command [arguments] [<keyword-arguments>]"""
def parse_options(kwargv):
    parser = argparse.ArgumentParser()
    parser.add_argument("--stage", type=str, required=False, help="staging root", default='stage')
    parser.add_argument("--debug", required=False, action="store_true", help="more debugging")
    parser.add_argument("--trace", required=False, action="store_true", help="show noisy exception traces")
    return parser.parse_args(kwargv)

def parse_args():
    posargv,kwargv = splitargv(sys.argv[1:])
    command = posargv[0] if len(posargv) else None
    posargs = posargv[1:]
    options = parse_options(kwargv)
    return command,posargs,options

@timedsingle
def dispatch(command,posargs,options=None):
    log.debug("command='%s', posargs=%s, options=%s" % (command,posargs,options))
    handler = etlapp.command.resolve(command)
    log.info("%s %s .." % (command,posargs))
    if handler:
        try:
            return handler(posargs,options)
        except (ValueError, RuntimeError) as e:
            if TRACE:
                log.exception(e)
            log.error(str(e))
            return False
    else:
        log.error("unrecognized command '%s'" % command)
        return False

def main():
    global TRACE
    command,posargs,options = parse_args()
    if options.debug:
        etlapp.logging.setlevel(log,'debug')
    if options.trace:
        TRACE = True
    status,delta = dispatch(command,posargs,options)
    _status = 'OK' if status else 'FAILED'
    log.info("status = %s in %.3f sec" % (_status,delta))
    log.info("done")

if __name__ == '__main__':
    main()


