# Editable slides with python-pptx

Use a supplied deck as the template when available. Otherwise choose slide
geometry once and build native text, pictures, and tables. `doc-nix python`
provides python-pptx without a persistent Python environment.

```python
from pptx import Presentation
from pptx.oxml.xmlchemy import OxmlElement
from pptx.util import Inches, Pt

deck = Presentation()
deck.slide_width = Inches(13.333)
deck.slide_height = Inches(7.5)
slide = deck.slides.add_slide(deck.slide_layouts[6])
box = slide.shapes.add_textbox(Inches(0.8), Inches(0.6), Inches(11.7), Inches(1.2))
box.text_frame.word_wrap = True
run = box.text_frame.paragraphs[0].add_run()
run.text = "中文标题 / English title"
run.font.name = "Source Han Sans SC"
run.font.size = Pt(32)
east_asian = OxmlElement("a:ea")
east_asian.set("typeface", "Source Han Sans SC")
run._r.get_or_add_rPr().append(east_asian)
deck.save("/tmp/opencode/slides.pptx")
```

```bash
doc-nix python /tmp/opencode/make_slides.py
render-review /tmp/opencode/slides.pptx
```

- Apply the Latin and East Asian typeface to each newly created run, including
  tables. When editing an existing run, update its existing `a:ea` rather than
  appending duplicates. Template placeholder styles can override defaults.
- Allocate boxes for wrapped text with explicit margins and line spacing.
  Text is not automatically guaranteed to fit; inspect at actual slide size.
- Preserve picture aspect ratio (supply only width or height unless cropping is
  intentional). Keep figures, captions, and page numbers inside the slide bounds.
- Use native tables for editability, with deliberate row heights and cell
  margins. Do not turn the entire slide into a screenshot to conceal overflow.
- LibreOffice's review PDF may differ from PowerPoint; report concrete defects
  and font requirements. Deliver the PPTX, not just the review PDF.
