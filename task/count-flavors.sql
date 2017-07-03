--
-- A magical data cube (presented as a sequence of slices) which tells us 
-- the counts of various BBL flavors per data source.
-- Currently takes about 105 sec.

select x.prefix, x.source, x.flavor, x.uniqbbl, x.rowcount from (

  select 1 as rank, 'pluto' as prefix, 'building' as source, 'total' as flavor, count(*) as uniqbbl, sum(total) as rowcount from core.pluto_building_count union 
  select 2, 'pluto', 'building', 'valid', count(*), sum(total) from core.pluto_building_count where is_valid_bbl(bbl) union 
  select 3, 'pluto', 'building', 'regular', count(*), sum(total) from core.pluto_building_count where is_regular_bbl(bbl) union
  select 4, 'pluto', 'building', 'marginal', count(*), sum(total) from core.pluto_building_count where is_marginal_bbl(bbl) union
  select 5, 'pluto', 'building', 'degenerate', count(*), sum(total)  from core.pluto_building_count where is_degenerate_bbl(bbl) union 
  select 6, 'pluto', 'building', 'condo', count(*), sum(total)  from core.pluto_building_count where is_condo_bbl(bbl) union 

  select 1, 'pluto', 'taxlot', 'total', count(*), NULL from core.pluto_taxlot union 
  select 2, 'pluto', 'taxlot', 'valid', count(*), NULL from core.pluto_taxlot where is_valid_bbl(bbl) union 
  select 3, 'pluto', 'taxlot', 'regular', count(*), NULL  from core.pluto_taxlot where is_regular_bbl(bbl) union
  select 4, 'pluto', 'taxlot', 'marginal', count(*), NULL  from core.pluto_taxlot where is_marginal_bbl(bbl) union 
  select 5, 'pluto', 'taxlot', 'degenerate', count(*), NULL from core.pluto_taxlot where is_degenerate_bbl(bbl) union
  select 6, 'pluto', 'taxlot', 'condo', count(*), NULL from core.pluto_taxlot where is_condo_bbl(bbl) union

  select 1, 'acris', 'legal', 'total' as flavor, count(*), sum(total) from push.acris_legal_count union 
  select 2, 'acris', 'legal', 'valid', count(*), sum(total) from push.acris_legal_count where is_valid_bbl(bbl) union 
  select 3, 'acris', 'legal', 'regular', count(*), sum(total) from push.acris_legal_count where is_regular_bbl(bbl) union
  select 4, 'acris', 'legal', 'marginal', count(*), sum(total) from push.acris_legal_count where is_marginal_bbl(bbl) union 
  select 5, 'acris', 'legal', 'degenerate', count(*), sum(total) from push.acris_legal_count where is_degenerate_bbl(bbl) union
  select 6, 'acris', 'legal', 'condo', count(*), sum(total) from push.acris_legal_count where is_condo_bbl(bbl) union

  select 1, 'dcp', 'pad-adr', 'total' as flavor, count(*), NULL from push.dcp_pad_adr_count union
  select 2, 'dcp', 'pad-adr', 'valid', count(*), NULL from push.dcp_pad_adr_count where is_valid_bbl(bbl) union
  select 3, 'dcp', 'pad-adr', 'regular', count(*), NULL from push.dcp_pad_adr_count where is_regular_bbl(bbl) union
  select 4, 'dcp', 'pad-adr', 'marginal', count(*), NULL from push.dcp_pad_adr_count where is_marginal_bbl(bbl) union
  select 5, 'dcp', 'pad-adr', 'degenerate', count(*), NULL from push.dcp_pad_adr_count where is_degenerate_bbl(bbl) union
  select 6, 'dcp', 'pad-adr', 'condo', count(*), NULL from push.dcp_pad_adr_count where is_condo_bbl(bbl) union

  select 1, 'dcp', 'pad-bbl', 'total' as flavor, count(*), NULL from push.dcp_pad_bbl_count union
  select 2, 'dcp', 'pad-bbl', 'valid', count(*), NULL from push.dcp_pad_bbl_count where is_valid_bbl(bbl) union
  select 3, 'dcp', 'pad-bbl', 'regular', count(*), NULL from push.dcp_pad_bbl_count where is_regular_bbl(bbl) union
  select 4, 'dcp', 'pad-bbl', 'marginal', count(*), NULL from push.dcp_pad_bbl_count where is_marginal_bbl(bbl) union
  select 5, 'dcp', 'pad-bbl', 'degenerate', count(*), NULL from push.dcp_pad_bbl_count where is_degenerate_bbl(bbl) union
  select 6, 'dcp', 'pad-bbl', 'condo', count(*), NULL from push.dcp_pad_bbl_count where is_condo_bbl(bbl)

) as x order by prefix, source, rank;




/*
Where the counts come from:

  table push.pluto_taxlot            PK = BBL
  mview core.pluto_building_count    (group by BBL)
  table push.acris_legal_count       (group by BBL)

*/





