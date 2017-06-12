select a.* from flat.dhcr2015 a left join push.pluto b on a.bbl = b.bbl where b.bbl is null; 
