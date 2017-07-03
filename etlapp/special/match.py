import os
import copy
from tabulate import tabulate
from collections import OrderedDict
from etlapp.logging import log
from nycprop.identity import bbl2qblock
from etlapp.decorators import timedsingle
from etlapp.util.io import read_recs, save_recs
import etlapp.util.nycgeo as nycgeo
import etlapp.source
import etlapp.stage
import etlapp

def perform(posargs=None,options=None):
    log.debug("posargs=%s, options=%s" % (posargs,options))
    if len(posargs) == 0:
        return matchup()
    else:
        raise ValueError("invalid usage")

def matchup():
    log.info("..")
    infile = etlapp.stage.mkpath('export','dcp','condo-spec')
    if not os.path.exists(infile):
        raise ValueError("can't find infile '%s'" % infile)
    log.info("file ok!")
    recs = list(read_recs(infile))
    log.info("that be %d recs" % len(recs))
    pairs = list(unroll(recs))
    distinct = sorted(set(pairs))
    log.info("yields %d pairs (%d distinct)" % (len(pairs),len(distinct)))
    outfile = etlapp.stage.mkpath('special','dcp','condo-map',autoviv=True)
    outrecs = ({'unit':unit,'bank':bank} for unit,bank in distinct)
    save_recs(outfile,outrecs,header=('bank','unit'))
    log.info("done")
    return True

def unroll(recs):
    for r in recs:
        lo,hi,bank = int(r['lo_bbl']),int(r['hi_bbl']),(r['bill_bbl'])
        for unit in range(lo,hi+1):
            yield unit,bank



def match_olde():
    infile_acris = etlapp.stage.mkpath('export','acris','condo-maybe')
    infile_pluto = etlapp.stage.mkpath('export','pluto','condo-primary')
    log.info("..")
    if not os.path.exists(infile_acris):
        raise ValueError("can't find infile '%s'" % infile_acris)
    if not os.path.exists(infile_pluto):
        raise ValueError("can't find infile '%s'" % infile_acris)
    log.info("files ok!")
    acris = read_recs(infile_acris)
    pluto = read_recs(infile_pluto)
    status,delta = match_streams(pluto,acris)
    _status = 'OK' if status else 'FAIL'
    log.info("status = %s in %.3f sec" % (_status,delta))
    log.info("done")
    return True

"""
A quick hack to impose integer types on selected columns.
We'd prefer something more robust and flexible, but for now this is much preferable
to loading some large framework (e.g. pandas) to do this for us.
"""
def castint(r,keys):
    """
    Casts dict values (corresponding to the given sequence) to int, in-place.
    We also return the dict struct as a convenience for generator-type expressions.
    """
    for k in keys:
        if k in r:
            v = r[k]
            if v != '':
                r[k] = int(v)
    return r

def count_pair(pluto,acris):
    """We do this task often enough - generate a dict of len counts
    on a pair of sequence-providing objects for pluto and acris
    that we wrote a re-usable function for it."""
    count = {}
    count['pluto'] = len(pluto)
    count['acris'] = len(acris)
    return count

_intcols = (
    'bbl',
    'units_total','units_res','bldg_count','num_bldgs','year_built', # pluto columns
    'history_count','lot_max','condo_depth','docid_count'            # acris columns
 )
def loadstreams(_pluto,_acris):
    """
    A simple idiom to load the two respective streams of interest.
    Note that it assumed that sufficient checking of pre-conditions has been done by this,
    hence there's basically no error handling at this stage.
    """
    def cast(r):
        return castint(r,_intcols)
    log.debug("slurp pluto ..")
    pluto = list(cast(r) for r in _pluto)
    log.debug("slurp acris..")
    acris = list(cast(r) for r in _acris)
    return pluto,acris

def loadtables(_pluto,_acris):
    log.debug("..")
    pluto,acris = loadstreams(_pluto,_acris)
    count = count_pair(pluto,acris)
    log.debug("count = %s" % count)
    log.debug("pivot pluto ..")
    pluto = pivotrecs(pluto,inplace=True)
    log.debug("pivot acris..")
    acris = pivotrecs(acris,inplace=True)
    return pluto,acris


def pivotrecs(recs,inplace=False):
    """Pivots a stream of incomings, presumed to have at least one key 'bbl'
    (which is also presumed to be unique throughout the stream) into a nice OrderedDict
    struct of {bbl:r}, where :r is a deepcopy of the truncated record dict.

    An optiona flag, :inplace, performs the record-munging operation in-place
    rather than on cloned dict.  This will of course trash the incoming record stream,
    but will be significiantly faster (about 3x), round-trip.
    """
    d = OrderedDict()
    for r in recs:
        bbl = r['bbl']
        if not nycgeo.is_valid_bbl(bbl):
            raise ValueError("invalid BBL '%s' detected in input stream" % bbl)
        if bbl in d:
            raise ValueError("duplicate BBL '%s' detected in input stream" % bbl)
        rr = r if inplace else copy.deepcopy(r)
        del rr['bbl']
        d[bbl] = rr
    return d

def stagger(d):
    """Staggers an OrderedDict, presumed to be keyed on BBL entries, into a
    special bi-level (ordered) dict-of-dict struct based on the tuple (qblock,lot)
    for each BBL."""
    dd = OrderedDict()
    for bbl,r in d.items():
        qblock,lot = nycgeo.split_bbl(bbl,q=True)
        # log.debug("bbl=%s  > %s,%s" % (bbl,qblock,lot))
        if qblock not in dd:
            dd[qblock] = OrderedDict()
        dd[qblock][lot] = r
    return dd


def common_blocks(_pluto,_acris):
    pluto = set(_pluto.keys())
    acris = set(_acris.keys())
    both  = sorted(pluto.intersection(acris))
    p_not_a = sorted(pluto - acris)
    a_not_p = sorted(acris - pluto)
    log.debug("pluto - acris = %s" % str(p_not_a))
    log.debug("acris - pluto = %s" % str(a_not_p))
    count_pluto_only = sum(len(_pluto[k]) for k in p_not_a)
    count_acris_only = sum(len(_acris[k]) for k in a_not_p)
    log.info("pluto - acris = %d blocks, %d rows" % (len(p_not_a),count_pluto_only))
    log.info("acris - pluto = %d blocks, %d rows" % (len(a_not_p),count_acris_only))
    count = {}
    count['pluto'] = sum(len(_pluto[k]) for k in both)
    count['acris'] = sum(len(_acris[k]) for k in both)
    log.debug("pluto ^ acris = %d blocks, %d pluto rows, %d acris rows" % (len(both),count['pluto'],count['acris']))
    return both,count


def rowset(qblock,d):
    if len(d) == 0:
        return None
    return [
        [nycgeo.make_bbl(qblock=qblock,lot=lot)] + list(r.values())
        for lot,r in d.items()
    ]


def rangeify(keys):
    init,prev = (None,None)
    for k in keys:
        if init is None:
            init,prev = k,k
        elif k > prev+1:
            yield (init,prev)
            init,prev = k,k
        else:
            prev = k
    if prev is not None:
        yield (init,prev)


def dump_blocks(blocks,pluto,acris):
    for k in blocks:
        print("")
        print("pluto[%d] .." % k)
        rows = rowset(k,pluto[k])
        print(tabulate(rows))
        print("acris[%d] .." % k)
        rows = rowset(k,acris[k])
        # print(tabulate(rows))
        tuples = list(rangeify(acris[k].keys()))
        print("that be %d tuple(s):" % len(tuples))
        for a,b in tuples:
            depth = b-a+1
            print("%.4d-%.4d: %d" % (a,b,depth))
        # print(tuples)
        # print("acris[%d] = %s" % (k,acris[k]))

@timedsingle
def match_streams(_pluto,_acris):
    pluto,acris = loadtables(_pluto,_acris)
    count = count_pair(pluto,acris)
    log.info("count = %s" % count)
    pluto = stagger(pluto)
    acris = stagger(acris)
    count = count_pair(pluto,acris)
    log.info("count = %s" % count)
    common,count = common_blocks(pluto,acris)
    log.info("diff = %d blocks, %d pluto rows, %d acris rows" % (len(common),count['pluto'],count['acris']))
    dump_blocks(common,pluto,acris)
    return True




