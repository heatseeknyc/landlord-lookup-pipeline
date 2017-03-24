import sys
from extract.util.pdf import textify

infile = sys.argv[1]
with open(infile,"rb") as f:
    for i,text in enumerate(textify(f)):
        print("page[%d] = %s" % (i,text))

