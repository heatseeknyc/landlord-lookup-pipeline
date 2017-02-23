"""
An extermely simple deduper + scrubber for the HPD registration contacts file.

Note that the "scrubbing" process is specific to the state of health of the
incoming (raw) CSV file as received from HPD for the current release; future
releases may well have (will likely have) different kinds of errors, and so
this module will need to be updated accordingly.

But for the current (20161031) release of the contacts file, the brokenness
seems to take two forms, both easily treated:

    (1) unescaped double-quote characters (which otherwise would cause the
    postgres COPY command to keep blindly slurping -- in come cases across
    multiple lines -- until it finds a closing double-quote char).

    (2) embedded pipe symbols (which are the current separator char), thus
    throwing off the row count for that line.

Current fixes are simply to delete all double-quote characters, and skip all
lines containing an unexpected number of pipe symbols (emitting them instead
to a "rejected" file for forensic analysis).
"""
import argparse
from collections import defaultdict
from extract.ioutil import save_lines
import extract.defaults

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=str, required=False, help="stage root", default=extract.defaults.root)
    return parser.parse_args()


def strip(lines):
    for line in lines:
        yield line.rstrip()

def dedup(sequence):
    """
    Yields a dedup'd version of an input sequence of objects (presumably strings), preserving order.

    Note that since the deduping relies on the behavior of the builting hash() function,
    treats certain values as equivalent, regardless of type (e.g. True, 1.0 and 1 will
    all hash to the same value), which makes this function unsuitable as a general-purpose
    deduper.  That's why the intended use case is to be applied over a sequence of values
    that are uniform in type, e.g. strings.
    """
    seen = set()
    for line in sequence:
        if line not in seen:
            seen.add(line)
            yield line

def scrub(lines):
    for line in lines:
        yield line.replace('"','')

def kount(lines):
    x = defaultdict(int)
    for line in lines:
        x[line.count("|")] += 1
    return x


def sift(lines):
    total = 0
    accept,reject = [],[]
    for line in lines:
        if line.count("|") == 14:
            accept.append(line)
        else:
            reject.append(line)
        total += 1
    return accept,reject,total

def process(path):
    with open(path,"rtU") as f:
        lines = dedup(scrub(strip(f)))
        return sift(lines)

def main():
    args = parse_args()
    indir = "%s/unpack/hpdreg" % args.root
    infile = "%s/RegistrationContact.txt" % indir
    outdir = "%s/xtracted" % args.root
    clean,reject,total = process(infile)
    print("that be %d lines total (%d clean, %d rejected)" % (total,len(clean),len(reject)))
    outfile_clean = "%s/contacts-clean.csv" % outdir
    outfile_reject = "%s/contacts-rejected.csv" % outdir
    print("clean lines to '%s' .." % outfile_clean)
    save_lines(outfile_clean,clean)
    print("rejected lines to '%s' .." % outfile_reject)
    save_lines(outfile_reject,reject)
    print("done.")


if __name__ == '__main__':
    main()

