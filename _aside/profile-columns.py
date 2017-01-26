#
# Quick and dirty column profiler.
#
import sys
from collections import defaultdict

hist = defaultdict(int) 
for line in sys.stdin:
    line = line.rstrip()
    terms = line.split('|')
    hist[len(terms)] += 1

print(hist)


