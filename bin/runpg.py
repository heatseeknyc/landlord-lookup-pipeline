#!/opt/ana3/bin/python
#
# A simple argument packer for the standard postgres terminal.
# Assumes we'll be using the 'writeuser', whose password has been
# set in the default .pgpass location (per the setup instructions). 
#
# TODO: explain args + volatility
#
import sys
import simplejson as json
from subprocess import call

pgargs = sys.argv[1:]

configpath = "config/postgres.json"
pgconf = json.loads(open(configpath,"r").read())
    
# print("pgconf = ",pgconf)
# print("pgargs = ",pgargs)

flags = "-U %(user)s -d %(dbname)s" % pgconf
command = "psql %s %s" % (flags,' '.join(pgargs))
print("EXEC: %s" % command)
call(command,shell=True)


