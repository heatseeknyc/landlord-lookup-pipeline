import re
from . import load
from . import pull
from . import dump
from . import check
from etlapp.special import match


def resolve(command):
    funcname = "%s.perform" % command
    if not is_legit(command):
        raise ValueError("invalid command: %s" % funcname)
    try:
        handler = eval(funcname)
        return handler
    except Exception as e:
        raise ValueError("invalid command: %s" % funcname)



_pat = re.compile('^\w+$')
def is_legit(command):
    return bool(re.match(_pat,command))


def nope():
    """
    if command == 'load':
        return load.perform
    if command == 'pull':
        return pull.perform
    if command == 'dump':
        return dump.perform
    if command == 'match':
        return match.perform
    return None
    """

