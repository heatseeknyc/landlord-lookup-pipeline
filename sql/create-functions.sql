--
-- Various functions to scrub data, form unique identifiers out of composite keys, etc. 
--

begin;

-- A simple filter to determine whether we've been given a valid
-- YYYYMMDD string.  Not bullet proof by any means, but will at least
-- catch certain invalid cases we've seen so far. 
create or replace function public.is_valid_yyyymmdd (datestr text) 
returns boolean AS $$
begin
    return 
        datestr is not null and
        datestr ~ '^(19|20)(0\d|1[012])[0123]\d$' and
        datestr !~ '023\d$' and 
        datestr !~ '0431$' and 
        datestr !~ '0631$' and 
        datestr !~ '0931$' and 
        datestr !~ '1131$';
end
$$ language plpgsql;

create or replace function public.is_valid_bbl (bbl bigint) 
returns boolean AS $$
begin
    return 
      bbl is not null and
      bbl > 1000000000 and bbl < 6000000000 and 
      bbl not in (2000000000,3000000000,4000000000,5000000000);
end
$$ language plpgsql;

create or replace function public.is_valid_bin (bin integer) 
returns boolean AS $$
begin
    return 
      bin is not null and 
      bin > 1000000 and bin < 6000000 and 
      bin not in (2000000,3000000,4000000,5000000);
end
$$ language plpgsql;

create or replace function public.is_degenerate (bbl bigint) 
returns boolean AS $$
begin
    return 
      bbl is not null and
      bbl in (1000000000,2000000000,3000000000,4000000000,5000000000);
end
$$ language plpgsql;

-- A lot is said to he "marginal" if it's -not- "degenerate", -and- either 
-- its block or lot numbers are all zeros or all nines.  (SO the 'marginal' 
-- and 'degenerate' categories should be mutually exlusive
create or replace function public.is_marginal (bbl bigint) 
returns boolean AS $$
declare
    block integer := 0;
    lot smallint := 0;
begin
    if bbl is null then 
        return false; end if; 
    if bbl in (1000000000,2000000000,3000000000,4000000000,5000000000) then
        return false; end if; 
    lot := (bbl % 10000)::smallint;
    block := ((bbl % 1000000000)/10000)::integer;
    return block in (0,99999) or lot in (0,9999);
end
$$ language plpgsql;

create or replace function public.is_condo_primary (bbl bigint) 
returns boolean AS $$
declare
    lot smallint := 0;
begin
    if bbl is NULL then return false; end if;
    lot := cast(bbl % 10000 as smallint);
    return lot between 7501 and 7599;
end
$$ language plpgsql;

create or replace function public.is_condo_secondary (bbl bigint) 
returns boolean AS $$
declare
    lot smallint := 0;
begin
    if bbl is NULL then return false; end if;
    lot := cast(bbl % 10000 as smallint);
    return lot between 1001 and 6999;
end
$$ language plpgsql;

create or replace function public.is_coop_bldg_class (bldg_class char(2)) 
returns boolean AS $$
begin
    if bldg_class in ('A8','C6','C8','D0','D4','H7') then return true;
    else return false; 
    end if;
end
$$ language plpgsql;

-- 
-- Maps the composite key (boro_id,block,lot) to a properly typed (bigint) primary key.
--
create or replace function public.make_bbl (boro_id smallint, block integer, lot smallint) 
returns bigint AS $$
begin
    return cast(boro_id as bigint) * 1000000000 + cast(block as bigint) * 10000 + lot;
end
$$ language plpgsql;

create or replace function public.bbl2boro (bbl bigint) 
returns smallint AS $$
begin
    return cast(bbl/1000000000 as smallint);
end
$$ language plpgsql;

create or replace function public.bbl2block (bbl bigint) 
returns integer AS $$
begin
    return cast((bbl % 1000000000)/10000 as integer);
end
$$ language plpgsql;

create or replace function public.bbl2lot (bbl bigint) 
returns smallint AS $$
begin
    return cast(bbl % 10000 as smallint);
end
$$ language plpgsql;

-- A local convention (to our data model) that provides what we call the "fully qualified block", a 
-- 6-digit number which includes the borough id.  Useful for uniquely identifying blocks in a single column. 
create or replace function public.bbl2qblock (bbl bigint) 
returns integer AS $$
begin
    return cast(bbl/10000 as integer);
end
$$ language plpgsql;


-- 
-- Given a BBL, return the 2-letter Borough Code used in many GIS systems 
--
create or replace function public.bbl2code (bbl bigint) 
returns text AS $$
declare
    boro_code text := NULL;
    boro_id smallint := 0;
begin
    boro_id := cast(bbl / 1000000000 as smallint);
    if boro_id = 1 then boro_code = 'MN'; end if;
    if boro_id = 2 then boro_code = 'BX'; end if;
    if boro_id = 3 then boro_code = 'BK'; end if;
    if boro_id = 4 then boro_code = 'QS'; end if;
    if boro_id = 5 then boro_code = 'SI'; end if;
    return boro_code;
end;
$$ language plpgsql;

-- 
-- Given a BBL, returns the Borough name.
--
create or replace function public.bbl2boroname (bbl bigint) 
returns text AS $$
declare
    boro_name text := NULL;
    boro_id smallint := 0;
begin
    boro_id := cast(bbl / 1000000000 as smallint);
    if boro_id = 1 then boro_name = 'Manhattan'; end if;
    if boro_id = 2 then boro_name = 'Bronx'; end if;
    if boro_id = 3 then boro_name = 'Brooklyn'; end if;
    if boro_id = 4 then boro_name = 'Queens'; end if;
    if boro_id = 5 then boro_name = 'Staten Island'; end if;
    return boro_name;
end;
$$ language plpgsql;

create or replace function public.boroname2boroid (boro_name text) 
returns smallint AS $$
declare
    boro_id smallint = NULL;
begin
    boro_name = lower(boro_name);
    if boro_name = 'manhattan' then boro_id = 1; end if;
    if boro_name = 'bronx' then boro_id = 2; end if;
    if boro_name = 'brooklyn' then boro_id = 3; end if;
    if boro_name = 'queens' then boro_id = 4; end if;
    if boro_name = 'staten island' then boro_id = 5; end if;
    return boro_id;
end;
$$ language plpgsql;

-- Creates a short ("colloquial") contact name from first/middle/last components.
-- Naively assumes that each component has no leading/trailing whitespace. 
-- (Applies to contacts table only).
create or replace function public.make_contact_name (first text, middle text, last text) 
returns text as $$
begin
    if first is not NULL and first != '' then 
        first = first || ' ';
    end if;
    if middle is not NULL and middle != '' then 
        middle = middle || ' ';
    end if;
    return first || middle || last;
end 
$$ language plpgsql;

-- Creats a short-ish colloquial business address from generic components.
-- (Applies to contacts table only).
create or replace function public.make_contact_addr (
  house_number text, street_name text, apartment text, city text, state text, zip text) 
returns text as $$
begin
    if house_number is NULL then house_number = ''; end if;
    if street_name is NULL then street_name = ''; end if;
    if apartment is NULL then apartment = ''; end if;
    if city is NULL then city = ''; end if;
    if state is NULL then state = ''; end if;
    if zip is NULL then zip = ''; end if;

    if house_number != '' then 
        house_number = house_number || ' ';
    end if;
    if street_name != '' then 
        street_name = street_name || ' ';
    end if;
    if apartment ~ '^\d+$' then 
        apartment = 'Apt ' || apartment;
    end if;
    if apartment != '' then 
        apartment = apartment || ' ';
    end if;
    if city != '' then 
        city = city || ' ';
    end if;
    if state != '' then 
        state = state || ' ';
    end if;
    return house_number || street_name || apartment || city || state || zip;
end
$$ language plpgsql;

commit;

