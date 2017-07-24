import sys
from extract.util.pdf import textify
from extract.util.pdf import get_page, extract_all

#
# A simple demo of our PDF extraction util.
# DEPRECATED
#

def dump_all(f):
    page = get_page(f,13)
    for x,types,blocks in extract_all(page):
        print("operator = [%s]" % x)
        pairs = zip(types,blocks)
        for i,pair in enumerate(pairs):
            _type,block = pair
            print("op[%d] = %s, %s" % (i,_type,block))

def dump_text(f):
    for i,text in enumerate(textify(f)):
        print("page[%d] = %s" % (i,text))

infile = sys.argv[1]
with open(infile,"rb") as f:
    dump_all(f)

