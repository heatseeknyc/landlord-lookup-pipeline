import sys
import time
import argparse
from extract.util.io import read_recs, save_recs
from extract.taxbills.parse import consume, genrecs, corrupt
import extract.defaults

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=str, required=False, help="staging root", default=extract.defaults.root)
    # The following two flags are for troubleshooting only; not used in production.
    # This one limits the number of lines slurped (to stop before a bad line is detected,
    # or just to do a quicker run on a limited subset).  
    parser.add_argument("--limit", type=int, required=False, help="record limit", default=None)
    # This one creates degenerate records for testing purposes. 
    parser.add_argument("--corrupt", type=float, required=False, help="set fields to None with given probability", default=0.0)
    return parser.parse_args()


fields = ('bbl','active_date','owner_name','mailing_address')
def save_table(path,table):
    outrecs = genrecs(table)
    save_recs(path,outrecs,fields)

def main():
    args = parse_args()
    indir   = "%s/unpack" % args.root
    outdir  = "%s/xtracted" % args.root
    infile  = "%s/rawdata.csv" % indir
    outfile = "%s/taxbills-latest.csv" % outdir
    print("slurp '%s' .." % infile)
    recs = read_recs(infile)
    t0 = time.time()
    table = consume(recs,args.limit)
    delta = time.time() - t0
    print("slurp'd %d recs with %d distinct BBLs in %.3f sec.." % (table['total'],len(table['active']),delta))
    if args.corrupt:
        corrupt(table,args.corrupt)
    print("write to '%s' .." % outfile)
    save_table(outfile,table)
    print("done.")

if __name__ == '__main__':
    main()


