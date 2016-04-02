--
-- Various functions to scrub data, form unique identifiers out of composite keys, etc. 
--

begin;

-- 
-- Maps the composite key (boro_id,block,lot) to a properly typed (bigint) primary key.
--
create or replace function public.make_bbl (boro_id smallint, block smallint, lot smallint) 
returns bigint AS $$
begin
    return cast(boro_id as bigint) * 1000000000 + cast(block as bigint) * 10000 + lot;
end
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

