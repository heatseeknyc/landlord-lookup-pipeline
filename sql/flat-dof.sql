
begin;

drop table if exists flat.dof_rolling cascade;
create table flat.dof_rolling (
    borough smallint not null,
    neighborhood text,
    bldgclass_category text,
    taxclass_present char(2),
    block integer not null,
    lot smallint not null,
    easement text, -- nearly always empty
    bldgclass_present char(2),
    address text,
    apartment text,
    zipcode integer,
    units_resi integer,
    units_comm integer,
    units_total integer,
    sqft_land float,
    sqft_gross float,
    year_built smallint,
    taxclass_atsale char(2),
    bldgclass_atsale char(2),
    sale_price float,
    sale_date date
);

commit;

-- 'BOROUGH', 'NEIGHBORHOOD', 'BUILDING CLASS CATEGORY', 'TAX CLASS AT PRESENT', 'BLOCK', 'LOT', 'EASE-MENT', 'BUILDING CLASS AT PRESENT', 
-- 'ADDRESS', 'APARTMENT NUMBER', 'ZIP CODE', 'RESIDENTIAL UNITS', 'COMMERCIAL UNITS', 'TOTAL UNITS', 'LAND SQUARE FEET', 'GROSS SQUARE FEET', 
-- 'YEAR BUILT', 'TAX CLASS AT TIME OF SALE', 'BUILDING CLASS AT TIME OF SALE', 'SALE PRICE', 'SALE DATE']
-- 1,ALPHABET CITY,03 THREE FAMILY DWELLINGS                  ,1,376,24, ,C0,
-- 264 EAST 7TH   STREET, ,10009,3,0,3,2059,3696,
-- 1900, 1,C0,7738700,2016-12-22 00:00:00

