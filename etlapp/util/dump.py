from etlapp.util.csvarg import make_csv_args

def make_dump_command(table,outfile,char=','):
    csvargs = make_csv_args(char)
    # COPY products_273 TO '/tmp/products_199.csv' DELIMITER ',' CSV HEADER;^
    return "\copy %s TO %s %s;" % (table,outfile,csvargs)

