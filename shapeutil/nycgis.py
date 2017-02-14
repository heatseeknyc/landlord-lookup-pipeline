"""
Provides a simple convenience function for converting from stateplane
coordinates to standard lat/lon for the NYC GIS grid only, as specified
by the identifier

    NAD_1983_StatePlane_New_York_Long_Island_FIPS_3104_Feet

in the .prj for the building shapefiles we'll be loading.

"""
from pyproj import Proj

"""
The following construct is taken nearly verbatim (except for the callable name)
from the StackOverflow post:


which yields the output shown in the captured interpreter session shown below.
"""
_project_nyc = Proj(
    proj  = 'lcc',
    datum = 'NAD83',
    lat_1 = 40.666667,
    lat_2 = 41.033333,
    lat_0 = 40.166667,
    lon_0 = -74.0,
    x_0 = 984250.0,
    y_0 = 0.0
)
"""
    x,y = [981106.0],[195544.0]
    lon,lat = __project_nyc(x,y,inverse=True)
    print(lon,lat)
    ([-74.037898165369], [41.927378144152])

Note that in the snippet in the SO post the output tuple had more precision:
    ([-74.037898165369015], [41.927378144152335])
 """

def _stateplane2lonlat(easting,northing):
    """
    Converts a pair of (:easting,:northing) coordinates in the New York West
    stateplane (FIPS 3104) to standard lattitude and longitude.
    """
    x,y = [easting],[northing]
    lon,lat = _project_nyc(x,y,inverse=True)
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
    e,n = 981106.0,195544.0
    lon,lat = stateplane2lonlat(e,n)
    print(lon,lat)

if __name__ == '__main__':
    demo()

