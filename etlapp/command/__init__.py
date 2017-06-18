from . import load
from . import pull
from . import dump
from etlapp.special import match

def resolve(command):
    if command == 'load':
        return load.perform
    if command == 'pull':
        return pull.perform
    if command == 'dump':
        return dump.perform
    if command == 'match':
        return match.perform
    return None

