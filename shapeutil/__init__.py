"""
Provides a slightly simplified (and theoretically, generic) interface to
the standard shapefile library, to make our parsing tasks somewhat easier.

Or at least, mostly generic (as applies to the 'core' and 'extras' modules).
The 'nycgis' module contains a small, but critical coordinate projection function
which (as the name implies) is specific to NYC-based GIS calculations.  In principle,
this function should go under some other namespace (so as to keep the functionality
of this package strictly generic).  But for the time being we'll just accept that
piece of messines, so that we can get on with the work we need to do.
"""
import shapefile as sf
from . import core

def slurp(infile):
    reader = sf.Reader(infile)
    return core.ShapefileWrapper(reader)

