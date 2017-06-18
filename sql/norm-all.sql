--
-- The "norm" schema contains what are (usually) final-form, normalized 
-- relations for consumption by the REST API and/or CSV export. 
--

begin;

drop schema if exists norm cascade; 
create schema norm;

create view norm.acris_control as select * from flat.acris_control;
create view norm.acris_condo_maybe as select * from p1.acris_condo_maybe;

commit;

