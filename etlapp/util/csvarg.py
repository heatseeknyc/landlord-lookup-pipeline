"""
Idioms for CSV args for the psql COPY command.
"""

_valid_delim = set([',','|'])
def is_valid_delim(c):
    return c in _valid_delim

def delim_term(c):
    if not is_valid_delim(c):
        raise ValueError("invalid delimiter [%s]" % c)
    return '\\"'+c+'\\"'

def make_csv_args(c):
    delimstr = '' if c == ',' else "DELIMETER %s, " % delim_term(c)
    return '('+delimstr+'FORMAT CSV, HEADER TRUE)'


