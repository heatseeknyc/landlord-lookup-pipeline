"""
Filters the raw DHCR tuples file selecting for valid BBL/BIN pairs,
and saves these as a CSV file.
"""
import argparse
from extract.util.io import read_recs, save_recs
import extract.defaults

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=str, required=False, help="staging root", default=extract.defaults.root)
    return parser.parse_args()


def isgood(p):
    _bbl,_bin = p
    return len(_bbl) > 0 and len(_bin) > 0


def recs2pairs(recs):
    return ((r['bbl'],r['bin']) for r in recs)

def pairs2recs(pairs):
    return ({'bbl':_bbl,'bin':_bin} for _bbl,_bin in pairs)

def distinct(pairs):
    return sorted(set((r['bbl'],r['bin']) for r in recs))


def main():
    args = parse_args()
    indir   = "%s/incoming" % args.root
    outdir  = "%s/xtracted" % args.root
    infile  = "%s/dhcr_all_geocoded.csv" % indir
    outfile = "%s/dhcr_pairs.csv" % outdir
    print("slurp '%s' .." % infile)

    recs = list(read_recs(infile))
    pairs = recs2pairs(recs)
    good = list(filter(isgood,pairs))
    uniq = sorted(set(good))
    print("slurp'd %d recs; %d good, %d uniq" % (len(recs),len(good),len(uniq)))

    recs = pairs2recs(uniq)
    header = ('bbl','bin')
    print("write to '%s' .." % outfile)
    save_recs(outfile,recs,header=header)
    print("done.")

if __name__ == '__main__':
    main()


