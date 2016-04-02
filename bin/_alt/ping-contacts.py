import sys
sys.path.append("lib")

from nychpd.utils import slurp_json
from nychpd.agent import ContactAgent

bbl = int(sys.argv[1])

print("hi.")
pgconf = slurp_json("config/postgres.json") 
agent = ContactAgent(**pgconf)

r = agent.get_contacts(bbl)
print("r = ", r) 

print("done.")



