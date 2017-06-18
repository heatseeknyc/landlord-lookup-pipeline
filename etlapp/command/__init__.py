from . import load
from . import pull
from . import dump 

def resolve(command):
    if command == 'load':
        return load.perform
    if command == 'pull':
        return pull.perform
    if command == 'dump':
        return dump.perform
    return None

