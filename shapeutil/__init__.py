import shapefile as sf
from . import core

def slurp(infile):
    reader = sf.Reader(infile)
    return core.ShapefileWrapper(reader)

