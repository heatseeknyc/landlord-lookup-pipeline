import sys
sys.path.append("lib")
import simplejson as json

from nychpd.utils import slurp_json
from nychpd.agent import LookupAgent

rawaddr = sys.argv[1]

print("hi.")
pgconf = slurp_json("config/postgres.json") 
agent = LookupAgent(**pgconf)

bbl = int(rawaddr)
r = agent.get_buildings(bbl)
print("r = ", r) 
print("r = ", json.dumps(r)) 

print("done.")



