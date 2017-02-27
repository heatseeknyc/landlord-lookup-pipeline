import sys
import time
import argparse
from collections import OrderedDict
from itertools import islice
import ioany
import shapeutil
from shapeutil.extras import canonify
from shapeutil.nycgis import stateplane2lonlat
import extract.defaults

boro_tags = ('MN','BX','BK','QN','SI')

rspec = OrderedDict((
    ('BBL','int-float'),
    ('Address',None),
    ('AssessLand','float'),
    ('AssessTot','float'),
    ('BldgArea',None),
    ('BldgClass',None),
    ('CD',None),
    ('CondoNo',None),
    ('HistDist',None),
    ('LandUse',None),
    ('Landmark',None),
    ('NumBldgs',None),
    ('NumFloors','float'),
    ('OwnerType',None),
    ('OwnerName',None),
    ('PLUTOMapID',None),
    ('UnitsRes',None),
    ('UnitsTotal',None),
    ('YearBuilt',None),
    ('ZoneDist1',None),
    ('ZoneDist2',None),
    ('ZoneDist3',None),
    ('ZoneDist4',None),
    ('ZoneMap',None),
    ('SplitZone',None),
))
rfields = list(rspec.keys())
sfields = "lat_ctr,lon_ctr,radius,parts,points".split(",")

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=str, required=False, help="staging root", default=extract.defaults.root)
    parser.add_argument("--boro", type=str, required=False, help="boro tag")
    parser.add_argument("--limit", type=int, required=False, help="record limit")
    return parser.parse_args()

def load_boro(srcdir,tag):
    basepath = "%s/%sMapPLUTO" % (srcdir,tag)
    t0 = time.time()
    sfw = shapeutil.slurp(basepath)
    delta = time.time() - t0
    print("boro=%s: %d records in %.3f sec" % (tag,len(sfw),delta))
    return sfw

def _profile(records):
    rad_min,rad_max = None,None
    inv_bbl,inv_bin = 0,0
    for r in records:
        if r['BBL'] not in range(1000000000,5999999999):
            inv_bbl += 1
        radius = float(r['radius'])
        if rad_min is None or radius < rad_min:
            rad_min = radius
        if rad_max is None or radius > rad_max:
            rad_max = radius
    return inv_bbl,inv_bin,rad_min,rad_max

def profile(records):
    t = inv_bbl,inv_bin,rad_min,rad_max = _profile(records)
    print("invalid: bbl=%d, bin=%d; range(radius) = %s,%s" % t)

def sift(sfw,limit):
    bigrecs  = islice(sfw.bigrecs(normal=True,projection=stateplane2lonlat),limit)
    return list(canonify(bigrecs,rspec))

def process(indir,outdir,tags,limit=None):
    allrecs = []
    t0 = time.time()
    for tag in tags:
        sfw = load_boro(indir,tag)
        allrecs += sift(sfw,limit)
    delta = time.time() - t0
    print("yields %d normalized records in %.3f sec" % (len(allrecs),delta))
    profile(allrecs)
    outfile = "%s/mappluto.csv" % outdir
    outfields = tuple(rfields+sfields)
    print("write to '%s' .." % outfile)
    ioany.save_recs(outfile,allrecs,header=outfields)

def main():
    args = parse_args()
    if args.boro is not None:
        tags = [args.boro]
    else:
        tags = list(boro_tags)
    indir = "%s/unpack/pluto" % args.root
    outdir = "%s/xtracted" % args.root
    process(indir,outdir,tags,args.limit)
    print("done.")


if __name__ == '__main__':
    main()


