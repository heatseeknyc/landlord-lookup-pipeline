import sys
import time
import argparse
import apps.pluto as pluto
from apps.ioutil import read_recs, save_recs

boro_tags = ('MN','BX','BK','QN','SI')

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--srcdir", type=str, required=True, help="source directory")
    parser.add_argument("--profile", action="store_true", help="input file")
    return parser.parse_args()

def _read_recs(basedir):
    """Given a base directory, looks for each of the 5 borough-specific CSV files,
    slurps them, and emits a unified sequence of normalized records (as if it were
    slurping from one big file)."""
    for borotag in boro_tags:
        datafile = "%s/%s.csv" % (basedir,borotag)
        print("slurp '%s' .." % datafile)
        recs = read_recs(datafile)
        yield from (pluto.parse.normalize(r) for r in recs)

def load_recs(basedir):
    return list(_read_recs(basedir))

def profile(recs):
    allrec = list(recs)
    print("that be %d recs." % len(allrec))
    bblset = set(r['BBL'] for r in allrec)
    print("that be %d distinct BBLs." % len(bblset))


def main():
    args = parse_args()
    indir = "%s/pluto" % args.srcdir
    outfile = "%s/pluto-latest.csv" % args.srcdir
    t0 = time.time()
    normrecs = load_recs(indir)
    delta = time.time() - t0
    print("that be %d normalized recs in %.3lf sec." % (len(normrecs),delta))
    if args.profile:
        profile(normrecs)
    else:
        t0 = time.time()
        print("save to %s .." % outfile)
        count = save_recs(outfile,normrecs,header=pluto.parse.fields)
        delta = time.time() - t0
        print("wrote %d recs in %.3lf sec." % (count,delta))
    print("done.")




if __name__ == '__main__':
    main()


