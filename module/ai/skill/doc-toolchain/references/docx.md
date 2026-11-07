# Word documents

Use python-docx for direct control of styles, sections, tables, and headers;
use Pandoc for an approved Markdown document with a supplied reference DOCX.
Neither route needs pip: `doc-nix python` supplies python-docx and openpyxl.

```python
from docx import Document
from docx.oxml.ns import qn
from docx.shared import Pt

document = Document()
for style_name in ("Normal", "Title", "Heading 1", "Heading 2"):
    style = document.styles[style_name]
    style.font.name = "Source Han Sans SC"
    style.element.get_or_add_rPr().get_or_add_rFonts().set(
        qn("w:eastAsia"), "Source Han Sans SC"
    )
document.styles["Normal"].font.size = Pt(11)
document.add_heading("中文报告 / Report", level=1)
document.add_paragraph("把主智能体给出的定稿放在这里，不改措辞。")
document.save("/tmp/opencode/report.docx")
```

For a reference DOCX, start with the supplied file. If none is provided:

```bash
doc-nix pandoc --print-default-data-file reference.docx > /tmp/opencode/reference.docx
# Edit its styles with python-docx; do not replace a supplied template.
doc-nix pandoc /tmp/opencode/report.md \
  --reference-doc=/tmp/opencode/reference.docx -o /tmp/opencode/report.docx
render-review /tmp/opencode/report.docx
```

Use real heading styles and section geometry. Set CJK fonts for table/header
styles or runs that override Normal. Check repeated table headers, rows split
across pages, paragraph keep-with-next, and page breaks. Avoid squeezing content
by silently deleting text. Fields such as TOCs/page counts may need refreshing
in the Office consumer; inspect what the conversion actually shows.

The review PDF is produced by headless LibreOffice using the isolated temporary
profile. Deliver the DOCX itself when Word is requested, and report any layout
dependency on recipient fonts or Office rendering.
