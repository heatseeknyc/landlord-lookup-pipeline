import sys


dups = 0
seen = set()
for line in sys.stdin:
    if line not in seen:
        seen.add(line)
    else:
        dups += 1

print("that be %d uniques, %d dups." % (len(seen),dups))

