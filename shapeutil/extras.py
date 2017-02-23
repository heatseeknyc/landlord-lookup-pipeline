import re
import os
import glob
import math
from copy import deepcopy
from collections import OrderedDict
from itertools import chain
import simplejson as json

def centroid(bbox):
    lon_min,lat_min,lon_max,lat_max = bbox
    lon_ctr = (lon_min+lon_max)/2
    lat_ctr = (lat_min+lat_max)/2
    dx = lon_ctr-lon_min
    dy = lat_ctr-lat_min
    radius = math.sqrt(dx*dx+dy*dy)
    return lon_ctr,lat_ctr,radius

def interlace(pairs):
    for x,y in pairs:
        yield x
        yield y

def pivot_shape(s):
    lon_ctr,lat_ctr,radius = centroid(s['bbox'])
    points = list(interlace(s['points']))
    parts = list(s['parts'])
    return {
        'lon_ctr':lon_ctr, 'lat_ctr':lat_ctr, 'radius':radius,
        'points':points, 'parts':parts, 'bbox':s['bbox']
    }

def text2float(s,name):
    """
    Casts a string to float, or throws a custom exception otherwise.
    :s: a string (which should represent a floating point value)
    :name: field name (for diagnostics)
    """
    try:
        return float(s)
    except Exception as e:
        raise ValueError("invalid float value '%s' for field '%s'" % (s,name))

def hard_int(x,name):
    """
    Simply casts a float to int, verifying that the float, in fact, represents an integer.
    :x: a floating-point value (which should represent an integer)
    :name: field name (for diagnostics)
    """
    if isinstance(x,float):
        if x == int(x):
            return int(x)
        else:
            raise ValueError("non-integral float value for field '%s'" % tag)
    else:
        raise TypeError("expected float for field '%s'" % tag)

nullblock = '\x00' * 254
def is_nullish(s):
    """Returns True if a string s looks like it was meant to represent a NULL value, or False otherwise."""
    return s == '' or s == nullblock

def canonify_value(ftype,value,name):
    # print("hey",ftype,value,name)
    if is_nullish(value):
        return None
    if ftype is None:
        return value
    if ftype == 'int-float':
        x = text2float(value,name)
        return hard_int(x,name)
    if ftype == 'float':
        return text2float(value,name)
    raise ValueError("invaild ftype '%s' for field '%s'" % (ftype,name))

def _canonify_record(r,spec):
    for k,ftype in spec.items():
        v = canonify_value(ftype,r[k],k)
        yield k,v

def canonify_record(r,spec):
    return OrderedDict(_canonify_record(r,spec))

def canonify_bigrec(rr,spec):
    r = canonify_record(rr['record'],spec)
    s = canonify_shape(pivot_shape(rr['shape']))
    return OrderedDict(chain(r.items(),s.items()))

def canonify(bigrecs,spec):
    for rr in bigrecs:
        yield canonify_bigrec(rr,spec)

def _trunc(x):
    return float("%.6lf" % x)

def canonify_shape(s):
    v = OrderedDict() 
    for k in ('lon_ctr','lat_ctr','radius'):
        v[k] = _trunc(s[k])
    points = [_trunc(_) for _ in s['points']]
    v['points'] = json.dumps(points)
    v['parts'] = json.dumps(s['parts'])
    return v


def _pathtuples(dirpath):
    if not os.path.isdir(dirpath):
        raise ValueError("not a dir!")
    pat = "%s/*.*" % dirpath
    for path in glob.glob(pat):
        head,tail = os.path.split(path)
        base,ext = os.path.splitext(tail)
        yield head,base,ext

def find_basenames(dirpath,matching):
    """Given a directory path, returns the set of unique basenames of files in that
    directory which have extensions corresponding to a known matching set."""
    pathtups = _pathtuples(dirpath)
    goodbase = (base for head,base,ext in pathtups if ext in matching)
    return set(goodbase)

shapexts = ('dbf','prj','sbn','sbx','shp','shx') # canonical(?) list of shapefile extensions
matchset = set(".%s" % _ for _ in shapexts)      # same as the above with '.' prepended
def find_shapefile_basenames(dirpath):
    """Like find find_basenames, but hard-coded to match on the set of known
    shapefile extensions."""
    return find_basenames(dirpath,matchset)

# a cute alias for the above
findbase = find_shapefile_basenames


# deprecated
def __vec2str(vec,dtype):
    if dtype == float:
        middle = ",".join("%lf" % _ for _ in vec)
        return "[%s]" % middle
    if dtype == int:
        middle = ",".join("%d" % _ for _ in vec)
        return "[%s]" % middle
    raise ValueError("invalid dtype")

