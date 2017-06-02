import time
from functools import wraps


def timedsingle(func):
    @wraps(func)
    def called(*args,**kwargs):
        t0 = time.time()
        x = func(*args,**kwargs)
        delta = time.time() - t0
        return x,delta
    return called

def timedmulti(func):
    @wraps(func)
    def called(*args,**kwargs):
        t0 = time.time()
        t = func(*args,**kwargs)
        delta = time.time() - t0
        return tuple(list(t) + [delta])
    return called

def backoff(func=None,retry=1,interval=5,log=None):
    @wraps(func)
    def wrapped(*args,**kwargs):
         i = 0
         while i < retry:
             if log:
                 log.info("retry = %d .." % i)
             try:
                 return func(*args,**kwargs)
             except Exception as e:
                 if log:
                     log.info("WHOA count=%d, reason: = %s" % (i,e))
                     log.exception(e)
                 i += 1
                 time.sleep(interval)
         raise RuntimeError("retry limit exceeded")
    return wrapped
