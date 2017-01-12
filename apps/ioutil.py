"""
Some simple abstractions for CSV i/o.
"""
import csv

def read_csv(path,encoding="utf-8",csvargs=None):
    if csvargs is None:
        csvargs = {}
    with open(path,"rt",encoding=encoding) as f:
         yield from csv.reader(f,**csvargs)

def read_recs(path,encoding="utf-8",csvargs=None):
    reader = read_csv(path,encoding=encoding,csvargs=csvargs)
    header = None
    for i,values in enumerate(reader):
        if header is None:
            header = values
        else:
            if len(values) == len(header):
                yield dict(zip(header,values))
            else:
                raise ValueError("length mismatch between row and header at line %d" % i)

def save_recs(path,recs,header,encoding="utf-8",csvargs=None):
    if csvargs is None:
        csvargs = {}
    count = 0
    with open(path,"wt",encoding=encoding) as f:
         writer = csv.writer(f,**csvargs)
         writer.writerow(header)
         for r in recs:
             values = [r[k] for k in header]
             writer.writerow(values)
             count += 1
    return count

