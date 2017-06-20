from etlapp.util.csvarg import make_csv_args

"""
We use the '(select % from ...)' construct so that the relation we pull
from doesn't have to be table, as it would be if given as the direct argument
to the COPY command.  Introduces a very slight performance overhead, but is
vastly more flexible.
"""
def make_dump_command(table,outfile,char=','):
    csvargs = make_csv_args(char)
    return "\copy (select * from %s) TO %s %s;" % (table,outfile,csvargs)

