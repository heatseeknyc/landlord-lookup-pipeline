
begin;

drop table if exists flat.dcas_ipis cascade;
create table flat.dcas_ipis (
    boro smallint not null,
    block integer not null,
    lot smallint not null,
    parcel_name text,
    parcel_address text,
    juris text,
    jurisdiction_description text,
    rpad char(2),
    rpad_description text,
    prop_front integer,
    prop_depth integer, 
    prop_sqft integer,
    irregular char(1), 
    bld_front integer,
    bld_depth integer,
    bld_sqft integer,
    num_bld integer,
    floors float, 
    cd smallint,
    council_district smallint,
    council_member_name text,
    pr_zone text,
    ov_zone text,
    sd_zone text,
    bbl bigint not null,
    waterfront char(1),
    urban_renewal_site char(1),
    agency text,
    owned_leased char(1),
    primary_use char(20),
    final_commitment char(20),
    agreeement char(20)
);

drop table if exists flat.dcas_law48 cascade;
create table flat.dcas_law48 (

    date_created date not null,
    boro smallint not null,
    map smallint,
    block integer not null,
    lot smallint not null,
    address text,
    parcel_name text,
    agency text,
    current_uses text,
    total_area bigint,
    petroleum text, -- either 'Yes' or null
    cleanup text,

    structure_completed smallint,
    number_structures integer,
    total_gross_area_structures bigint,
    ratio_bldg2floor float,
    allow_bldg2floor float,
    land_use text,

    community_district smallint,
    census_tract text, -- sometimes float or junk like '9018A'
    census_block text, -- sometime junk
    school_dist smallint,
    council_district smallint,
    zipcode smallint,
    fire_comp char(4),
    health_area smallint,
    health_center smallint,
    police_prct smallint,
    major_use char(2),

    easements integer,
    comm_floor_area bigint,
    resi_floor_area bigint,
    office_floor_area bigint,
    retail_floor_area bigint,
    garage_floor_area bigint,
    storage_floor_area bigint,
    factory_floor_area bigint,

    other_floor_area bigint,
    floors float,
    resi_units integer,
    total_units integer,
    lot_front float,
    lot_depth float,
    bldg_front float,
    bldg_depth float,
    proximity smallint,

    irregular char(1),
    lot_type_code smallint,
    bsmt_code smallint,
    assess_land bigint, 
    exempt_land bigint, 
    exempt_total bigint, 
    year_alter_1 smallint,
    year_alter_2 smallint,
    hisdist text,
    landmark text,
    condo smallint,
    coordinates text,
    edesig text,
    ibz text,
    zone1 text,
    zone2 text,
    overlay1 text,
    overlay2 text,
    sp1 text,
    sp2 text,
    potential_urban text,
    contact text,
    occupied float,
    pluto text
);

commit;


