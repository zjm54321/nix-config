# Markdown slides with Marp

Choose Marp for Markdown-authored slides when PDF is the deliverable. Preserve
the approved words and use explicit slide breaks and font styling:

```markdown
---
marp: true
theme: default
paginate: true
style: |
  section { font-family: "Source Han Sans SC", sans-serif; }
  h1, h2 { font-family: "Source Han Sans SC", sans-serif; }
---
# 中文标题 / English title
已批准的第一张幻灯片内容。

---
# 第二张 / Second slide
已批准的第二张幻灯片内容。
```

```bash
doc-nix marp --pdf /tmp/opencode/slides.md -o /tmp/opencode/slides.pdf
render-review /tmp/opencode/slides.pdf
```

The wrapper supplies `--browser chrome --browser-path` using `google-chrome`
from PATH. For approved local images, add `--allow-local-files`; do not enable
local file access for untrusted Markdown. Keep images relative to the source
and avoid stretching them with mismatched dimensions. Use the required theme
and inspect slide overflow, contrast, figure fit, and page numbers.

Marp's ordinary `--pptx` output embeds one rendered image per slide; it is not
editable text/shapes. Switch the authoring choice to python-pptx at the outset
when the user requires editable slides. Do not label a raster deck as editable.
