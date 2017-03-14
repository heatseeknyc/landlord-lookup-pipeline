"""
Filters the raw DHCR tuples file selecting for valid BBL/BIN pairs,
and saves these as a CSV file.
"""
import argparse
from extract.ioutil import read_recs, save_recs
import extract.defaults

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=str, required=False, help="staging root", default=extract.defaults.root)
    return parser.parse_args()


def isgood(r):
    return len(r['bbl']) > 0 and len(r['bin']) > 0


def main():
    args = parse_args()
    indir   = "%s/incoming" % args.root
    outdir  = "%s/xtracted" % args.root
    infile  = "%s/dhcr_all_geocoded.csv" % indir
    outfile = "%s/dhcr_tuples.csv" % outdir
    print("slurp '%s' .." % infile)
    recs = list(read_recs(infile))
    tiny = ({'bbl':r['bbl'],'bin':r['bin']} for r in recs)
    good = list(filter(isgood,tiny))
    print("slurp'd %d recs, %d good" % (len(recs),len(good)))
    header = ('bbl','bin')
    print("write to '%s' .." % outfile)
    save_recs(outfile,good,header=header)
    print("done.")

if __name__ == '__main__':
    main()


