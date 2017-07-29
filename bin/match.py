import re
import sys
import argparse
from collections import defaultdict;
import ioany
import etlapp.stage as stage


print("slurp ..")
path = stage.filepath('export','acris','declare-simple');
reciter = ioany.read_recs(path);
recs = list(reciter)
print("that be %d recs." % len(recs))


def sift(recs):
    total = 0;
    pairs = set()
    taxlot = set()
    docmap = defaultdict(set);
    for r in recs:
        bbl,docid,doctype = r['bbl'],r['docid'],r['doctype']
        pairs.add((bbl,docid))
        docmap[docid].add(doctype)
        taxlot.add(bbl)
        total += 1
    count = {};
    count['total'] = total
    count['pairs'] = len(pairs)
    count['docid'] = len(docmap)
    count['multi'] = sum(1 for _ in docmap if len(docmap[_]) > 0)
    count['bbl'] = len(taxlot)
    return count,pairs,docmap


print("sift ..")
count,pairs,docmap = sift(recs)
print(count)





