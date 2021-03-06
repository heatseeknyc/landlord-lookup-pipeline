--
-- Various functions to scrub data, form unique identifiers out of composite keys, etc. 
--

begin;

--
-- Functions related to BBLs
--

--
-- A useful, but somewhat risky "spaceship" operator, a la <=> in Perl.
--
-- Risky in that your inputs better be of compatible types, otherwise it will 
-- blow up!  And in that you can easily confuse NULL status for equality!
--
create or replace function public.cmp (x anyelement, y anyelement)
returns integer AS $$
begin
    if x = y then return 0; end if;
    if x < y then return -1; end if;
    if x > y then return +1; end if;
    return null; 
end
$$ language plpgsql;


-- We call a BBL "valid" if it is at least structurally valid, 
-- that is, integer and not completely out of range.
create or replace function public.is_valid_bbl (bbl bigint) 
returns boolean AS $$
begin
    return 
      bbl is not null and
      bbl >= 1000000000 and bbl < 6000000000;
end
$$ language plpgsql;

-- A BBL is 'degenerate' (or informally, a 'billion'-BBL) if all of its 
-- non-leading digits are zero.  There are no real lots (either physical or 
-- financial) with these numbers; but in practice these numbers are used as 
-- stand-ins for NULL.
create or replace function public.is_degenerate_bbl (bbl bigint) 
returns boolean AS $$
begin
    return 
      bbl is not null and
      bbl in (1000000000,2000000000,3000000000,4000000000,5000000000);
end
$$ language plpgsql;

-- A lot is said to he "marginal" if its valid, but -not- "degenerate", and 
-- either its block or lot numbers are all zeros or all nines.  Note in particular
-- that the 'marginal' and 'degenerate' categories are mutually exclusive.
create or replace function public.is_marginal_bbl (bbl bigint) 
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

--
-- Finally, a BBL is said to be "regular" if it is valid but neither degenerate
-- nor marginal.  That is to say, it may or may not be in any of the city's databases 
-- (or it might be in one more database, but its presence there is questionable)  --
-- and there's no way of knowing whether it's a "bank/bill" BBL, a condo unit, or
-- a vanilla tax lot -- but at least we know that it's structurally valid and not 
-- "marked for deprecation".
--
create or replace function public.is_regular_bbl (bbl bigint) 
returns boolean AS $$
begin
    return is_valid_bbl(bbl) and not (is_degenerate_bbl(bbl) or is_marginal_bbl(bbl));
end
$$ language plpgsql;

-- An overlfow BBL has a lot number above the condo range, but is still not
-- marginal.  These are sometimes used as placeholder or temporary BBLs.
create or replace function public.is_overflow_bbl (bbl bigint) 
returns boolean AS $$
declare
    block integer := 0;
    lot smallint := 0;
begin
    if bbl is null then 
        return false; end if; 
    lot := (bbl % 10000)::smallint;
    return lot between 7600 and 9998;
end
$$ language plpgsql;

create or replace function public.is_condo_bbl (bbl bigint) 
returns boolean AS $$
declare
    lot smallint := 0;
begin
    if bbl is NULL then return false; end if;
    lot := cast(bbl % 10000 as smallint);
    return lot between 7501 and 7599;
end
$$ language plpgsql;


-- The next two functions return a smallint signifying the strucrutal
-- category of a BBL or BIN, respectively.
--
-- Note that the categories are mutually exclusive (and should cover all
-- inputs, assuming their underlying deermination functions are working 
-- propertly).  


--
-- Returns a smallint signifying the structural cetegory for the given BBL:
--
--     { 0:invalid, 1:regular, 2:degenerate, 3:marginal }
--
-- It will always return a number in the range 0-3. 
--
create or replace function public.bbl2type (bbl bigint) 
returns smallint AS $$
declare
    block integer := 0;
    lot smallint := 0;
begin
    if bbl is null or bbl < 1000000000 or bbl >= 6000000000
        then return 0; end if;  -- invalid
    if bbl in (1000000000,2000000000,3000000000,4000000000,5000000000)
        then return 2; end if;  -- degenerate
    block := ((bbl % 1000000000)/10000)::integer;
    lot := (bbl % 10000)::smallint;
    if block in (0,99999) or lot in (0,9999)
        then return 3; end if;  -- marginal
    return 1;                   -- regular
end
$$ language plpgsql;


--
-- Returns a smallint signifying the structural cetegory for the given BIN:
--
--     { 0:invalid, 1:regular, 2:degenerate }
--
-- It will always return a number in the range 0-2. 
--
create or replace function public.bin2type (bin integer) 
returns smallint AS $$
begin
    if bin is null or bin < 1000000 or bin >= 6000000
        then return 0; end if;  -- invalid
    if bin in (1000000,2000000,3000000,4000000,5000000)
        then return 2; end if;  -- degenerate
    return 1;                   -- regular
end
$$ language plpgsql;




-- DEPRECATED 
/*
create or replace function public.is_condo_secondary (bbl bigint) 
returns boolean AS $$
declare
    lot smallint := 0;
begin
    if bbl is NULL then return false; end if;
    lot := cast(bbl % 10000 as smallint);
    return lot between 1001 and 6999;
end
$$ language plpgsql; */


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


--
-- Functions related to BINs (Building Identification Numbers)
--

create or replace function public.is_valid_bin (bin integer) 
returns boolean AS $$
begin
    return 
      bin is not null and 
      bin >= 1000000 and bin < 6000000;
end
$$ language plpgsql;

-- So-called "million" BINs with all zeros.
create or replace function public.is_degenerate_bin (bin integer) 
returns boolean AS $$
begin
    return 
      bin is not null and 
      bin in (1000000,2000000,3000000,4000000,5000000);
end
$$ language plpgsql;

-- A BIN is "regular" if it is valid and not degenerate. 
create or replace function public.is_regular_bin (bin integer) 
returns boolean AS $$
begin
    return 
      bin is not null and 
      bin > 1000000 and bin < 6000000 and 
      bin not in (2000000,3000000,4000000,5000000);
end
$$ language plpgsql;


--
-- Miscellaneous functions
-- 

-- A simple filter to determine whether we've been given a valid
-- YYYYMMDD string.  Unfortunately not quite bulletproof:  while it
-- will catch almost all invalid date strings, it won't detect
-- "rogue leap year" dates, that is, 02/29 dates on a non leap-year.
create or replace function public.is_valid_yyyymmdd (datestr text) 
returns boolean AS $$
begin
    return 
        datestr is not null and
        datestr ~ '^(18|19|20)(0[1-9]|1[012])[0123]\d$' and
        datestr !~ '3[2-9]$' and 
        datestr !~ '023\d$' and 
        datestr !~ '0431$' and 
        datestr !~ '0631$' and 
        datestr !~ '0931$' and 
        datestr !~ '1131$';
end
$$ language plpgsql;

-- Similar to the above, but verifies that we're in the format 'MMxDDxYYYY', 
-- where x is an arbitary separator char.  (Yes, this not quite congruent ,
-- as a use case, because of the separator.  But that's OK, because most 
-- likely if you're using MMDDYYYY, you'll be using a separator).
-- Has similar caveats as the above function.
create or replace function public.is_valid_mmddyyyy (datestr text) 
returns boolean AS $$
begin
    return 
        datestr is not null and
        datestr ~ '^(0[1-9]|1[012])\D[0123]\d\D(18|19|20)\d\d$' and
        datestr !~ '^..3[2-9]' and 
        datestr !~ '^02.3' and 
        datestr !~ '^04.31' and 
        datestr !~ '^06.31' and 
        datestr !~ '^09.31' and 
        datestr !~ '^11.31';
end
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

create or replace function public.is_coop_bldg_class (bldg_class char(2)) 
returns boolean AS $$
begin
    if bldg_class in ('A8','C6','C8','D0','D4','H7') then return true;
    else return false; 
    end if;
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

create or replace function public.mkflags_acris (
    easement boolean, partial char(1), rights_air boolean, rights_sub boolean)
returns char(7) as $$
begin
    return partial::text ||'-'|| 
        easement::integer::text ||'-'|| 
        rights_air::integer::text ||'-'|| 
        rights_sub::integer::text;
end
$$ language plpgsql;

-- Ignoring country field for now.  And it definitely has some holes in terms of
-- elegeantly patching up non-existant fields.  But should work about 95% of the time.
create or replace function public.mkaddr_acris (
  address1 text, address2 text, country text, city text, state text, postal text) 
returns text as $$
begin
    address1 = coalesce(address1,'');
    address2 = coalesce(address2,'');
    country = coalesce(country,'');
    city = coalesce(city,'');
    state = coalesce(state,'');
    postal = coalesce(postal,'');

    if address1 != '' and address2 != '' then address1 = address1 || ', '; end if;
    if city != '' then city = city || ', '; end if;
    if state != '' then state = state || ' '; end if;

    return address1||address2 ||' - '||city||state||postal;
end
$$ language plpgsql;


--
-- The next 3 functions are generally for scrubbing fixed-width fields.
--

-- A simple "normalize fixed-width string" function which returns NULL if
-- the input looks NULL-ish (that is, is all spaces), or the TRIM'd version
-- of the string, otherwise.
create or replace function public.normfw (s text)
returns text as $$
begin
    if s is null or s ~ '^\s*$' then return null;
    else return trim(s);
    end if;
end
$$ language plpgsql;

--
-- Analogous to normfw(), but for cases where we're expecting our column to
-- be a cleanly formatted integer (perhaps padded with spaces on either sidee), 
-- or a string of blank spaces.  Either way, we return an integer if we can 
-- reasonably cast to one, or null otherwise.
--
-- Note that "dirty" strings (e.g. with embedded spaces or non-digit chars)
-- will be simply cast to NULL; and it will simply choke on longer digit strings
-- which should really be returned as bigints.  So you have to be on the lookout
-- for that, and only use this function if you feel confident that your data
-- meet the criteria above.
---
-- XXX could perhaps be made more performant by using regexes to capture 
-- space-embedded integers (rather than calling the trim() function beforehand,
-- each and every time).
create or replace function public.soft_int (s text)
returns integer as $$
begin
    if s is null then return null; end if;
    s = trim(s);
    if s ~ '^\d+$' then return s::integer; end if;
    return null;
end
$$ language plpgsql;

--
-- Analogous to the above two functions, for the case where the BBL is presented
-- in fixed-width fields (with similar caveats).  To be used only where your raw
-- fields are very clean (that is, where youre characters are either all digits,
-- or all blanks spaces).
--
-- XXX similar performance caveats was with the soft_int() function.
create or replace function public.soft_bbl (boro_id text, block text, lot text)
returns bigint AS $$
begin
    if boro_id is null or block is null or lot is null then
        return null; end if;
    boro_id = trim(boro_id);
    block = trim(block);
    lot = trim(lot);
    if boro_id ~ '^\d{1}$' and block ~ '^\d{1,5}$' and lot ~ '^\d{1,4}$' then
        return make_bbl(boro_id::smallint, block::integer, lot::smallint); end if;
    return null;
end
$$ language plpgsql;

commit;

