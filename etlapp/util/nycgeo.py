import re
"""
Various generic support functions for the NYC real estate data ecosystem.
"""

def is_valid_bbl(bbl):
    """Determins whether the given :bbl is structurally valid, meaning simply:
    an integer 10 digits in length, starting with digits 1-5.  The intent is simply
    to filter outright 'junk' BBLs that can't possibly have a valid interpretation,
    and would basically never occur in the city's databases.  Keep in mind though
    that even though a BBL is considered 'valid' it may still be unsuitable for
    a whole bunch of reasons."""
    return isinstance(bbl,int) and bbl >= 1000000000 and bbl < 6000000000

def is_valid_boro(boro):
    return isinstance(boro,int) and boro >= 1 and boro < 6

def is_valid_block(block):
    return isinstance(block,int) and block >= 0 and block < 100000

def is_valid_lot(lot):
    return isinstance(lot,int) and lot >= 0 and lot < 10000

def is_valid_qblock(qblock):
    return isinstance(qblock,int) and qblock >= 100000 and qblock < 600000

def is_valid_bin(bin_):
    """Determins whether the given :bin is structurally valid, meaning simply:
    an integer 7 digits in length, starting with digits 1-5.  As with the method
    of a similar name that determines whether a BBL is 'valid', the intent is
    simply to identify 'junk' BINs that can't possibly have a valid interpretation,
    and would basically never occur in the city's databases.  Keep in mind though
    that even though a BIN is considered 'valid' it may still be unsuitable for
    a whole bunch of reasons."""
    return isinstance(bin_,int) and bin_ >= 1000000 and bin_ < 6000000

#
# Yes, there's a lot of repetition in next 5 assertion functions, given that 
# they all have basically the same error message. But structuring them this way 
# keeps the exception traces easier to comprehend.
#
# BTW, we include the type information in the exception trace for the (quite 
# likely to occur) case that a variable of some non-integer type (e.g. a str) 
# was fed in.
#
def assert_valid_bbl(bbl):
    if not is_valid_bbl(bbl):
        raise ValueError("invalid bbl '%s' of type %s" % (bbl,type(bbl)))

def assert_valid_boro(boro):
    if not is_valid_boro(boro):
        raise ValueError("invalid boro ID '%s' of type %s" % (boro,type(boro)))

def assert_valid_block(block):
    if not is_valid_block(block):
        raise ValueError("invalid block '%s' of type %s" % (block,type(block)))

def assert_valid_lot(lot):
    if not is_valid_lot(lot):
        raise ValueError("invalid lot '%s' of type %s" % (lot,type(lot)))

def assert_valid_qblock(qblock):
    if not is_valid_qblock(qblock):
        raise ValueError("invalid qblock '%s' of type %s" % (qblock,type(qblock)))


def bbl2boro(bbl):
    assert_valid_bbl(bbl)
    return bbl // 1000000000

def bbl2block(bbl):
    assert_valid_bbl(bbl)
    return (bbl//100000) % 100000

def bbl2lot(bbl):
    assert_valid_bbl(bbl)
    return bbl % 10000

def split_bbl(bbl,q=False):
    """Splits a BBL into a tuple of (boro,block,lot), where each of the components are ints.
    Of the :q flag evaluates to True, then it splits into a tuple of (qblock,lot)."""
    return _split_bbl_qualified(bbl) if q else _split_bbl(bbl)

def _split_bbl(bbl):
    assert_valid_bbl(bbl)
    boro,blocklot = divmod(bbl,1000000000)
    block,lot = divmod(blocklot,10000)
    return boro,block,lot

def _split_bbl_qualified(bbl):
    """Like split_bbl, but returns a tuple of (qblock,lot)"""
    assert_valid_bbl(bbl)
    qblock,lot = divmod(bbl,10000)
    return qblock,lot

def bbl2qblock(bbl):
    """
    Returns the so-called 'qblock', or fully-qualified block number for a BBL.
    The 'qblock' is the 6-digit number corresponding to the catenation of of the
    tuple (boro,block) which uniquely identifies a block throughout the city.
    """
    assert_valid_bbl(bbl)
    return bbl // 10000

def make_bbl(boro=None,block=None,lot=None,qblock=None):
    if qblock is not None and (boro is not None or block is not None):
            raise ValueError("invalid usage - 'qblock' argument incompatible with 'boro' and 'block' arguments")
    return _make_bbl_with_qblock(qblock,lot) if qblock is not None else _make_bbl_standard(boro,block,lot)

def _make_bbl_standard(boro,block,lot):
    assert_valid_boro(boro)
    assert_valid_block(block)
    assert_valid_lot(lot)
    return boro * 1000000000 + block * 10000 + lot

def _make_bbl_with_qblock(qblock,lot):
    assert_valid_qblock(qblock)
    assert_valid_lot(lot)
    return qblock * 10000 + lot

_bblpat = re.compile('^\d{9}$')
def cast_bbl(s):
    if isinstance(s,str) and re.match(_bblpat,s):
        n = int(s)
        if is_valid_bbl(n):
            return n
    raise ValueError("invalid bbl argument '%s' of type %s" % (s,type(s)))


