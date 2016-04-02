import sys
sys.path.append("lib")

from nychpd.geo.utils import split_address 

raw = sys.argv[1]
upper = len(sys.argv) > 2

t = split_address(raw,upper)
print(t)

