# Chinese fonts without installation

The authoring/conversion wrappers fetch `source-han-sans` and `source-han-serif`
from the system-pinned nixpkgs. They set `TYPST_FONT_PATHS` and a temporary
`FONTCONFIG_FILE` that includes system fonts plus the fetched font directories.
Fontconfig caches are under `/tmp/opencode/fontconfig-cache`. No profile or
system font configuration changes are made.

- Use `Source Han Sans SC` for simplified-Chinese slides and headings, and
  `Source Han Serif SC` for long prose. Use `TC` or `HC` when the regional
  glyph forms are requested. A supplied font requirement takes priority.
- A font attribute/package name is not its family name. Check exact families
  with `doc-nix typst fonts`. The host's `fc-match "Source Han Sans SC"` can
  diagnose installed fonts, but does not show wrapper-only fonts.
- Typst: set `text(font: "Source Han Serif SC", lang: "zh")`; an explicit
  fallback tuple is useful for mixed scripts, but inspect which font renders.
- Tectonic: use `ctexart` with `fontset=none` and explicit `\setCJKmainfont` /
  `\setCJKsansfont`. Do not rely on a platform-specific ctex font preset.
- DOCX: set style/run fonts and `w:rFonts/@w:eastAsia`; `font.name` alone only
  sets Western font slots. Apply this to headings and table styles as needed.
- PPTX: set run fonts and `a:rPr/a:ea/@typeface`; a Latin typeface alone may
  leave Chinese text using the template's fallback.
- Marp: use an explicit CSS font-family; the wrapper exposes the fonts to
  Chrome through fontconfig.

Open every rendered page. Tofu, unexpected glyph shapes, missing punctuation,
or a change in line wrapping can reveal fallback even when export succeeds.
Check PDF embedding when delivering to another machine: the sibling wrapper
can be used to get `pdfinfo`, while `nix shell nixpkgs#poppler-utils -c pdffonts
file.pdf` lists embedded fonts. Editable Office files depend on the recipient's
fonts; mention that requirement instead of treating the review PDF as proof
that every recipient will have the same layout.
