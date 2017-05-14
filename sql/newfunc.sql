begin;

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

commit;
 
