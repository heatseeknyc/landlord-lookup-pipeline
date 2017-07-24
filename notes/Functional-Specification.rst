A lightweight functional specification, as such. 

While not overly detailed, we do try to keep it up-to-date with the actual available feature sets in the running portal. 
In particular:
- If a feature is listed here, it really SHOULD be implemented in the portal by now (or there should be immiment plans to do so) 
- Conversely, if some major feature exists in the portal here, it should at least be mentioned here.

So while the app + spec might be off on minor points of detail -- in terms of the big picture and major bullet points, 
they should be not just roughly, but strongly in synch.


Datasets
--------

This section really needs a separate page.  For now, it might help to say:

We currently aggregate from about 25 datasets from various city agencies, including most of the better-known datasets (ACRIS, PAD, Pluto, HPD, DOB, etc) and a few lesser-known ones.  Thankfully we have Socrata to rely on for the more common ones, but there are a few corner cases that are somewhat fussier to deal with (invovling Excel or PDF scraping, for example).

But one way or another it all happens, and the portal gets updated whenever the datasets update (monthly, for most of them - though some update on a much more irregular basis). 



Frontend / UX
-------------

A single-page application (SPA) for now.

Two modes of entry:
 - Route(1): User types in an address or BBL in the search window
 - Route(2): User lands there via a taxlot URL ('/taxlot/<bbl>'). 

Note that even though the '/taxlot/' URL suggests that the user will be accessing a different page,
really these will just be internal redirects to the same top-level page (and equivalent to an accces
on that page with a certain query string).

Detail as to the routes:

Route(1): 
 - This is expected to be the more common route of access.  Two forms of 
   input are accepted - <address> or <bbl>.  


Route(2):
 - This will be functionally equivalent to typing a <bbl> in the search form 
   (except that they won't see the BBL in the search form, but in the URL).
 

Autocomplete
------------

The search form should include some form of autocomplete functionality. 
Currently Google Autocomplete works well enough (and was easy to implement).

But in the future we should think of ways to "tidy" it up.  In particular, ideally it should: 
 - Provide NYC addresses only.
 - Have these provide just the fields (street address, borough) and perhaps zip5, 
   but nothing else (definitely not state or 'US').


Property Summary
----------------

'Property' or 'Building' summary...


Ownership
---------


Error Handling
--------------

Errors should be handled in a meaningful way that does not seem obtrusive to the overall user experience.  

I don't have time to elucidate further on that, other than to note that we've all seen websites with bad error handling, so the only prescription I can provide as the moment is "don't do those things." 


External Links
--------------

It'd be nice to provide links to external services, e.g. OASIS, ACRIS, DOB, HPD, etc where these are known to be useful and stable (and of course, URL-addressible).  In principle this is quite easy.  The catch is that not every service provides data for very BBL -- e.g. ACRIS has data for BBLs referencing condo units, but if you put in the primary taxlot number, it comes up empty. 

REST endpoints
--------------

Currently these are intended to serve the web application only.  And we should probably keep it that way.  If we want to provide data services (per se), we should probably provide a completely separate gateway for that, even if they end up being largely congruent to these services.:

 - '/lookup/<query>', 
 - '/contact/<bbl,bin>' 
 - '/building/<bbl>'
    


Future Behaviors
----------------
In no particular order:
 - Lending Information
 - Better data for condos / coops. 
 - Disentangle the "zombie BBL" mess.
 - Toggle map display between light/dark/noisy tile sets (currently we only support 'noisy' tiles).
   Noisy tiles are find (ideal, actually) for viewing single properties and small assemblages, 
   but for dispersed clusters (and city-wide views) the sparser tile sets would be better. 
 - Look up property by name (e.g. 'The Dakota')
 - More continous updating (e.g. daily) for complaints, violations, and ownerhship (transfers). 



