select bbl,taxclass,bldg_count as bldgs,bldg_class,land_use,units,stable,estimated,amount,risk::float(2),past 
from temp.atrisk where year = 2017 and stable > 0 and council = 2 order by risk desc;
