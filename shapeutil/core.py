from collections import OrderedDict
import shapefile


class ShapefileWrapper(object):

    def __init__(self,reader):
        self.reader = reader
        self.build()

    def build(self):
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
        return {
            'shape': self.shape(i,normal,projection),
            'record': self.record(i,normal)
        }

    def bigrecs(self,normal=False,projection=None):
        for i in range(0,len(self)):
            yield self.bigrec(i,normal,projection)

def _normstr(v):
    """
    Normalizes extracted strings.  Specifically, converts bytes objects to
    str objects, and strips whitespace on all strings (regardless of origin 
    type).
    """
    if isinstance(v,bytes):
        return v.decode('utf-8').strip()
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
    """Applies a coordinate projection :f to a normalized :shape dict, in-place."""
    shape['points'] = list(map(f,shape['points']))
    shape['bbox'] = apply_bbox(f,shape['bbox'])



