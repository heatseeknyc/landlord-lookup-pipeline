from PyPDF2 import PdfFileReader
from PyPDF2.utils import isString, b_
from PyPDF2.pdf import ContentStream
from PyPDF2.generic import TextStringObject
import ioany

def extract_text_objects(page):
    """Yields a sequence of TextStringObject instances from a given PageObject,
    in whatever order the internal content stream chooses to emit them.
    
    Note that the order may change as the PyPDF2 package evolves.
    
    Adapted directly from the extractText method of the PageObject class
    from PyPDF2.pdf."""
    content = page["/Contents"].getObject()
    if not isinstance(content, ContentStream):
        content = ContentStream(content, page.pdf)
        for operands, operator in content.operations:
            if operator == b_("Tj"):
                _text = operands[0]
                if isinstance(_text, TextStringObject):
                    yield _text
            elif operator == b_("T*"):
                yield "\n"
            elif operator == b_("'"):
                yield "\n"
                _text = operands[0]
                if isinstance(_text, TextStringObject):
                    yield _text
            elif operator == b_('"'):
                _text = operands[2]
                if isinstance(_text, TextStringObject):
                    yield "\n"
                    yield _text
            elif operator == b_("TJ"):
                for x in operands[0]:
                    if isinstance(x, TextStringObject):
                        yield x
                yield "\n"

def extract_text(reader,strip=True):
    if strip:
        yield from (str(_).strip() for _ in extract_text_objects(reader))
    else:
        yield from (str(_) for _ in extract_text_objects(reader))

def textify(f):
    reader = PdfFileReader(f)
    return (list(extract_text(p)) for p in reader.pages)

def convert(infile,outfile):
    with open(infile, "rb") as f:
        for i,text in enumerate(textify(f)):
            print("text[%d] = %s" % (i,text))

def _convert(infile,outfile):
    reader = PdfFileReader(open(infile, "rb"))
    print("pages = ",type(reader.pages))
    for i,p in enumerate(reader.pages):
        text = list(extract_text(p))
        print("text[%d] = %s" % (i,text))

