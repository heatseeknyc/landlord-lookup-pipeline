from . import load
from . import pull

def resolve(command):
    if command == 'load':
        return load.perform
    if command == 'pull':
        return pull.perform
    return None

