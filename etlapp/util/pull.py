import etlapp.source
import etlapp.stage

def make_url(slug):
    template = "https://data.cityofnewyork.us/api/views/%s/rows.csv?accessType=DOWNLOAD"
    return template % slug

def make_pull_command(prefix,name,segment=None):
    if segment is not None:
        raise NotImplementedError("segments not supported in this operation")
    slug  = etlapp.source.getval(prefix,name,'slug',strict=True)
    url   = make_url(slug)
    destfile = etlapp.stage.mkpath('incoming',prefix,name,autoviv=True)
    return "curl -o %s '%s'" % (destfile,url)



