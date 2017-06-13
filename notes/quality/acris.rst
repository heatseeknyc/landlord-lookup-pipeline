

``acris.master``

(May, 2017)

(1) The raw file yielded the following, upon initial attempts at loading:

  ERROR:  date/time field value out of range: "02/29/0200"
  CONTEXT:  COPY acris_master, line 11732761, column date_document: "02/29/0200"

Due to lines like this:

  1448775:2010012200028003,A,2010000033589,2,ASST,05/29/0200,0,01/29/2010,01/29/2010,0,0,0,0,07/31/2015
  2565592:2008061701035003,A,2008000260374,1,CERT,04/29/0200,0,06/30/2008,06/30/2008,0,0,0,0,07/31/2015
  3851268:2010021201205001,A,2010000071286,1,PREL,10/29/0200,0,03/02/2010,03/02/2010,0,0,0,0,07/31/2015

Fix: regex check on the date field before casting.


(2) About 749 rows with duplicate instances of "DocID"

Or was it 749 duplicate DocID's across N rows?  
Are they (always) corrections, or sometimes something different?

Either way, we don't know how to interpret these duplcated DocIDs at present --  
so are fix is simply to drop them, via a special de-duping step in the ``push`` schema.


