
def kwindex(argv):
    """Returns the array position of the first keyword-like argument (that is, the
    first argument that starts with a dash."""
    i = 0
    while i < len(argv) and not argv[i].startswith('-'):
        i += 1
    return i

def splitargv(argv):
    """Splits an argument vector into positional and keyword arguments."""
    i = kwindex(argv)
    return argv[:i],argv[i:]

