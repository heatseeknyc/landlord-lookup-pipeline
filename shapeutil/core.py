from collections import OrderedDict
import shapefile


class ShapefileWrapper(object):
    """
    Provides some a somewhat simpler interface to shape and record structs
    as they typically occur in shapefile datasets, out in the wild.

    This class is hardly fully-featured, but was designed with genericity
    in mind (so there's nothing in this class specific to the datasets we're
    workking with) -- in keeping with basic "separation of concerns"
    considerations.
    """

    def __init__(self,reader):
        self.reader = reader
        self._build()

    def _build(self):
        self.fields = self.reader.fields
        self.shapes = self.reader.shapes()
        self.records = self.reader.records()
        self._build_labels()

    def _build_labels(self):
        if self.fields[0][0] == 'DeletionFlag':
            self.labels = [f[0] for f in self.fields[1:]]
            self.dtype  = [f[1] for f in self.fields[1:]]
            self.typemap = OrderedDict(zip(self.labels,self.dtype))
        else:
            raise ValueError("invalid shapfile")

    def __len__(self):
        return len(self.shapes)

    def assert_valid_index(self,i):
        if i not in range(0,len(self)):
            raise ValueError("invalid index")

    def record_items(self,i,normal=False):
        self.assert_valid_index(i)
        keys = self.labels
        vals = self.records[i]
        if normal:
            normval = map(_normstr,vals)
            return zip(keys,normval)
        else:
            return zip(keys,vals)

    def record(self,i,normal=False):
        items = self.record_items(i,normal)
        return OrderedDict(items)

    def shape(self,i,normal=False,projection=None):
        self.assert_valid_index(i)
        if normal:
            shape = self._shape_normal(i)
        else:
            shape = self._shape_raw(i)
        if projection:
            if not normal:
                raise ValueError("invalid usage -- projections can be applied only on normalized shapes")
            apply_projection(projection,shape)
        return shape

    def _shape_normal(self,i):
        """
        Returns a dict representation of a shape record with array-like components
        cast as lists (as shapefile._Array objects don't serialize).
        """
        shape = self.shapes[i]
        return {
            'bbox':list(shape.bbox),
            'points':list(shape.points),
            'parts':list(shape.parts),
            'type':shape.shapeType
        }

    def _shape_raw(self,i):
        """
        Returns a dict representation of a shape record with all members as-is.
        """
        shape = self.shapes[i]
        return {
            'bbox':shape.bbox,
            'points':shape.points,
            'parts':shape.parts,
            'type':shape.shapeType
        }

    def bigrec(self,i,normal=False,projection=None):
        """Returns a combined (or "big") record structure with 'shape' and 'record'
        components on a given integer index.
        
        :i: integer index.
        :normal: flag - if set to True, the respective components are subjected
        to an additional data cleansing) step (which makes the records subsantailly
        easier to use, but which of course also obscures their original form; and
        might possibly break when reading degenerate source files, e.g. with bad
        character encodings).

        :projection: a function, which, if supplied, is applied to the outgoing
        cartesian coordinates in the 'shape' member record.  The constraints (and 
        intended use cases) for this function are described in the 'apply_projection'
        callable in this module.
        """
        return {
            'shape': self.shape(i,normal,projection),
            'record': self.record(i,normal)
        }

    def bigrecs(self,normal=False,projection=None):
        """Provides an iterator of combined shape/record structs.  If optional
        :normal or :projection arguments are supplied, then these are passed
        on to the per-item :bigrec accessor."""
        for i in range(0,len(self)):
            yield self.bigrec(i,normal,projection)

def _normstr(v,encoding=None):
    """
    Normalizes extracted strings.  Specifically, converts bytes objects to
    str objects, and strips whitespace on all strings (regardless of origin
    type).
    """
    if isinstance(v,bytes):
        # return v.decode('utf-8').strip()
        if encoding is not None:
            return v.decode(encoding).strip()
        else:
            return str(v).strip()
    if isinstance(v,str):
        return v.strip()
    else:
        return v

def apply_bbox(f,bbox):
    """Applies a coordinate projection :f to a bbox list struct.."""
    e1,n1,e2,n2 = bbox
    lon1,lat1 = f((e1,n1))
    lon2,lat2 = f((e2,n2))
    return [lon1,lat1,lon2,lat2]

def apply_projection(f,shape):
    """
    Applies a coordinate projection :f to a normalized :shape dict, in-place.

    There are no constraints on the projection function, other than that it take
    a 2-tuple as its sole argument (corresponding to the fact that it also returns a
    2-tuple).  But the use case typically envisioned is a transformation from one 
    coordinate grid to another, e.g. stateplane to standard lat/lon.
    """
    shape['points'] = list(map(f,shape['points']))
    shape['bbox'] = apply_bbox(f,shape['bbox'])



