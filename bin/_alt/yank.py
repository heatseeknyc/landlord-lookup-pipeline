import sys
from collections import defaultdict

seen = set()
aggr = defaultdict(list)
for line in sys.stdin:
    line = line.rstrip();
    if line not in seen:
        seen.add(line)
        contact_id = line.split('|')[0]
        aggr[contact_id].append(line)

for contact_id in aggr:
    if len(aggr[contact_id]) > 1:
        for line in aggr[contact_id]:
            print(line)


