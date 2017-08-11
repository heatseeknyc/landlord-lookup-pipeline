"""
Provides a simple convenience function for converting from stateplane
coordinates to standard lat/lon for the NYC GIS grid only, as specified
by the identifier

    NAD_1983_StatePlane_New_York_Long_Island_FIPS_3104_Feet

in the .prj for the building shapefiles we'll be loading.

"""
import pyproj


"""
An alternate way of referencing the NYS projection, per the following issue writeup:

  https://github.com/jswhit/pyproj/issues/67

Note the 'preserve_units' flag, which turns out to be crucial.

"""
_convert = pyproj.Proj(init="EPSG:2263", preserve_units=True)

def _stateplane2lonlat(easting,northing):
    """
    Converts a pair of (:easting,:northing) coordinates in the New York West
    stateplane (FIPS 3104) to standard lattitude and longitude.
    """
    x,y = [easting],[northing]
    lon,lat = _convert(x,y,inverse=True)
    return lon[0],lat[0]

def stateplane2lonlat(t):
    """
    Converts a tuple :t representing a pair of (easting,northing) coordinates in the
    New York West stateplane (FIPS 3104) to standard lattitude and longitude.

    Note that the argument signature (acting on a 2-tuple, rather than two positional
    arguments; compatible with the output signature) was chosen so that this function
    can be more easily applied in iterative contexts (e.g. on a sequences of coordinate
    tuples).
    """
    return _stateplane2lonlat(*t)

def demo():
    """A simple unit test, as it were.  Returns a coordinate pair almost exactly 
    in the middle of Ellis Island."""
    e,n = 981106.0,195544.0
    lon,lat = stateplane2lonlat(e,n)
    print(lon,lat)

if __name__ == '__main__':
    demo()

