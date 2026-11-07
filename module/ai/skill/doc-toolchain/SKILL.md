---
name: doc-toolchain
description: >-
  Typeset finalized content into PDF, DOCX, or PPTX with an on-demand Nix
  document toolchain. Use whenever the typesetter or scribe team needs to
  compile Typst/LaTeX, produce Word documents or slides, convert Office files
  to PDF, or render and visually inspect every page, especially Chinese or
  mixed Chinese/English documents. Fetch tools temporarily; never install them
  into a system or user profile.
---

# Document toolchain

Preserve the approved content verbatim. Change layout, fonts, and technical
markup only; send content problems back to the lead agent. Use the requested
template and final output path. Keep sources, logs, conversion PDFs, and review
images under `/tmp/opencode` unless the lead specifies source deliverables.

## Choose one authoring route

| Deliverable | Route | Read next |
| --- | --- | --- |
| Markdown report → PDF | Pandoc → Typst, or a Typst source | [Typst](references/typst.md) |
| Paper → PDF / LaTeX | LaTeX with Tectonic (XeTeX) | [LaTeX](references/latex.md) |
| Editable slides → PPTX | python-pptx | [PPTX](references/pptx.md) |
| Markdown slides → PDF | Marp | [Marp](references/marp.md) |
| Word → DOCX | python-docx, or Pandoc with a reference DOCX | [DOCX](references/docx.md) |

Stick to that route; Office-to-PDF conversion is for review, not a second
authoring route. Marp's ordinary PPTX export is raster slides, not editable
slide objects. Use python-pptx when editability matters.

## Call the bundled wrappers

Resolve the directory of this loaded skill; the scripts need not be on PATH.

```bash
DOC_NIX="/absolute/path/to/doc-toolchain/scripts/doc-nix"
REVIEW="/absolute/path/to/doc-toolchain/scripts/render-review"
"$DOC_NIX" --help
"$DOC_NIX" typst compile /tmp/opencode/main.typ /tmp/opencode/main.pdf
"$DOC_NIX" python /tmp/opencode/make_slides.py
"$REVIEW" /tmp/opencode/main.pdf
```

`doc-nix <tool> [args…]` supports `typst`, `tectonic`, `pandoc`, `pdfinfo`,
`pdftoppm`, `marp`, `soffice`, and `python`. Python includes python-pptx,
python-docx, and openpyxl. Each call uses `nix shell`, pinned to the current
system's `/etc/nix/registry.json` entry for `nixpkgs`, including the Python
environment. Pandoc can call Typst; Marp uses `google-chrome` from PATH;
LibreOffice uses `/tmp/opencode/lo-profile`.

## Compile, render, and fix

1. Generate the chosen source and compile/export it. Save long stdout/stderr
   to a log under `/tmp/opencode`; read the relevant error and the log tail.
2. On failure, fix the reported technical cause and retry, at most **three
   fix rounds** after the initial attempt. Stop and report the log and blocker
   if compilation still fails. Do not rewrite content to make it fit.
3. Run `render-review <file.pdf|.docx|.pptx> [outdir]`. It converts Office files
   to PDF, prints PDF page count/size, and lists every rendered PNG. The default
   is `/tmp/opencode/review/<basename>/`; each run has a fresh subdirectory so
   stale pages cannot pass for current output.
4. Open **every** listed PNG with the available image viewer. Check missing
   glyphs/tofu and unintended font fallback; overflow/clipping; missing or
   distorted figures; broken or split tables; headers, footers, page numbers;
   TOC entries and numbering. Compilation alone is not visual verification.
5. Fix layout defects, regenerate the artifact, and re-render/reinspect every
   page. Retain the latest review paths. If the remaining defect cannot be
   fixed within the brief, report it rather than changing the content.

## Chinese fonts

Default to **Source Han Sans SC** for simplified-Chinese headings/slides and
**Source Han Serif SC** for long-form prose; use TC/HC for the requested region.
Follow supplied typography instead when it is specified. The wrappers expose
both Source Han families temporarily to Typst and fontconfig consumers; merely
putting a font package in `nix shell` does not register its fonts. Set OOXML
East Asian fonts explicitly for DOCX/PPTX. Read [CJK fonts](references/cjk-fonts.md)
before typesetting Chinese.

## Troubleshooting

- **First-run download:** Nix may fetch a large closure; Tectonic separately
  fetches its TeX bundle/files into its own user cache. Allow a long foreground
  timeout and keep the log. Report network/bundle errors; do not install tools
  permanently. Nix GC can remove tools; the next call simply fetches them again.
- **Font not found / tofu:** confirm the exact family with `doc-nix typst fonts`,
  then check explicit CJK/OOXML font settings. Do not accept a silent fallback.
- **LibreOffice profile lock:** do not run conversions concurrently with this
  profile. Wait for its active process to finish. Remove a stale
  `/tmp/opencode/lo-profile/.lock` only after confirming no process uses that
  profile; never kill an unrelated Office session. A successful exit without
  the expected PDF is a conversion failure, and `render-review` reports it.

## Deliver

- Final path(s), format, and actual page/slide count.
- Authoring route and commands used; sources only if requested.
- Every page reviewed, issues corrected, and any remaining issue or blocker.
- Final artifact exists and is readable; deliver the editable DOCX/PPTX when
  requested, not just its review PDF. Keep review intermediates out of delivery.
