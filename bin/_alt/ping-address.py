import sys
sys.path.append("lib")

from nychpd.utils import slurp_json
from nychpd.agent import AddressAgent

rawaddr = sys.argv[1]

print("hi.")
pgconf = slurp_json("config/postgres.json") 
agent = AddressAgent(**pgconf)

r = agent.get_bbl(rawaddr)
print("r = ", r) 

print("done.")



