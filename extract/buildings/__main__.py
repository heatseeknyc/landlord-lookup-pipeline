import sys
import time
import argparse
from collections import OrderedDict
from itertools import islice
import ioany
import shapeutil
from shapeutil.extras import findbase, canonify
import extract.defaults

rspec = OrderedDict((
    ('bbl','int-float'),
    ('bin','int-float'),
    ('doitt_id','int-float'),
    ('date_lstmo',None),
    ('cnstrct_yr',None),
    ('feat_code',None),
    ('built_code',None),
    ('name',None),
))
rfields = "bbl,bin,doitt_id".split(",")
sfields = "lat_ctr,lon_ctr,radius,parts,points".split(",")

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=str, required=False, help="staging root", default=extract.defaults.root)
    parser.add_argument("--limit", type=int, required=False, help="record limit")
    return parser.parse_args()

def _profile(records):
    rad_min,rad_max = None,None
    inv_bbl,inv_bin = 0,0
    for r in records:
        if r['bbl'] not in range(1000000000,5999999999):
            inv_bbl += 1
        if r['bin'] not in range(1000000,5999999):
            inv_bin += 1
        radius = float(r['radius'])
        if rad_min is None or radius < rad_min:
            rad_min = radius
        if rad_max is None or radius > rad_max:
            rad_max = radius
    return inv_bbl,inv_bin,rad_min,rad_max

def profile(records):
    t = inv_bbl,inv_bin,rad_min,rad_max = _profile(records)
    print("invalid: bbl=%d, bin=%d; range(radius) = %s,%s" % t)


def uniqbase(indir):
    """Given a directory path, finds the (presumably) unique shapefile basename
    for that directory (that is, the unique basename for all shapefiles in that
    directory).  If no such basename, or multiple basesnames are found, an
    exception is thrown."""
    basenames = list(findbase(indir))
    if len(basenames) < 1:
        raise ValueError("invalid usage - input dir '%s' contains no shapefiles" % indir)
    if len(basenames) > 2:
        raise ValueError("invalid usage - input dir '%s' contains too many shapefile basenames" % indir)
    return basenames[0]

def main():
    args = parse_args()
    indir = "%s/unpack/buildings" % args.root
    basename = uniqbase(indir)
    infile = "%s/%s" % (indir,basename)
    outdir = "%s/xtracted" % args.root
    outfile = "%s/buildings.csv" % outdir

    t0 = time.time()
    print("building shapes from %s .." % infile)
    sfw = shapeutil.slurp(infile)
    delta = time.time() - t0
    print("that be %d records in %.3f sec" % (len(sfw),delta))
    t0 = time.time()
    bigrecs  = islice(sfw.bigrecs(normal=True),args.limit)
    allrecs = list(canonify(bigrecs,rspec))
    delta = time.time() - t0
    print("normalized to %d recs in %.3f sec; profiling .." % (len(allrecs),delta))
    t0 = time.time()
    profile(allrecs)
    delta = time.time() - t0
    print("profiled in %.3f sec." % delta)
    outfields = tuple(rfields+sfields)
    print("write to '%s' .." % outfile)
    ioany.save_recs(outfile,allrecs,header=outfields)
    print("done.")


if __name__ == '__main__':
    main()

