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

schema = 'flat'
stage  = 'stage'
srcpath = sys.argv[1]

configpath = "config/postgres.json"
pgconf = json.loads(open(configpath,"r").read())

_valid_delim = set([',','|'])
def is_valid_delim(c):
    return c in _valid_delim

def delim_term(c):
    if not is_valid_delim(c):
        raise ValueError("invalid delimiter [%s]" % c)
    return '\\"'+c+'\\"'

def make_csv_args(c):
    return "(DELIMITER %s, FORMAT CSV, HEADER TRUE)" % delim_term(c)

def tablename(schema,prefix,sname):
    return "%s.%s_%s" % (schema,prefix,sname)

def source2prefix(srcpath):
    terms = srcpath.split('.')
    if len(terms) > 1:
        return terms[0]
    raise ValueError("invalid source path [%s]" % srcpath)

def splitpath(srcpath):
    terms = srcpath.split('.')
    if len(terms) == 2:
        return tuple(terms)
    raise ValueError("invalid source path [%s]" % srcpath)

def make_copy_cmd(table,infile,char):
    csvargs = make_csv_args(char)
    return "\copy %s FROM %s %s;" % (table,infile,csvargs)


prefix,sname = splitpath(srcpath)
indir = '%s/xtracted/%s' % (stage,prefix)
infile = "%s/%s.csv" % (indir,sname)
table = tablename(schema,prefix,sname)
copycmd = make_copy_cmd(table,infile,',')

quoted = '"'+copycmd+'"'
flags = "-U %(user)s -d %(dbname)s" % pgconf
command = "psql %s -c %s" % (flags,quoted)
print("EXEC: %s" % command)
call(command,shell=True)


# print("copy = %s" % copycmd)
# print("indir = %s" % indir)
# print("infile = %s" % infile)
# print("table = %s" % table)

"""
copycmd = "\copy flat.acris_master_codes FROM ./stage/xtracted/acris/master-codes.csv (DELIMITER \",\", FORMAT CSV, HEADER TRUE);"
EXEC: psql -U writeuser -d nyc8 -c "\copy flat.acris_master_codes FROM ./stage/xtracted/acris/master-codes.csv (DELIMITER \",\", FORMAT CSV, HEADER TRUE);"
COPY 123
"""

