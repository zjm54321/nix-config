# Typst reports

Use Typst directly for controlled page layout; use Pandoc's Typst engine for
an approved Markdown report. Keep assets relative to the source document.

```typst
#set page(paper: "a4", margin: 2cm, numbering: "1")
#set text(font: "Source Han Serif SC", size: 11pt, lang: "zh")
#show heading: set text(font: "Source Han Sans SC")
= 项目报告 / Project report
中文与 English 可以在同一段落排版。
#table(
  columns: (1fr, 2fr), inset: 6pt,
  table.header([项目], [说明 / Description]),
  [排版], [保持定稿内容不变],
)
#pagebreak()
= 第二页 / Second page
检查页码、表格和中文标点。
```

```bash
doc-nix typst compile /tmp/opencode/main.typ /tmp/opencode/main.pdf
doc-nix pandoc /tmp/opencode/report.md -o /tmp/opencode/report.pdf \
  --pdf-engine=typst -V mainfont="Source Han Sans SC"
render-review /tmp/opencode/main.pdf
```

For a supplied template, retain its page geometry and map approved content to
its fields. For large tables, use `table.header` for repeated headers and check
page breaks; avoid fixed-height containers around flowing prose. Preserve
image aspect ratios, give captions room, and verify numbering/TOC after the
last compile. Resolve unknown-font warnings before reviewing, not by deleting
the Chinese text. Use `doc-nix typst fonts` to check exact family names.
