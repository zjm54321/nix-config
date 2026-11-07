# LaTeX with Tectonic

Tectonic uses the XeTeX engine. Prefer `ctexart` for Chinese articles, with
explicit fonts rather than the distribution's default ctex font preset:

```tex
\documentclass[UTF8,fontset=none]{ctexart}
\usepackage[a4paper,margin=25mm]{geometry}
\setmainfont{Source Han Serif SC}
\setsansfont{Source Han Sans SC}
\setCJKmainfont{Source Han Serif SC}
\setCJKsansfont{Source Han Sans SC}
\begin{document}
\section{中文与 English}
这是一份保持内容不变的排版示例。Chinese and English text.
\end{document}
```

If the required template uses `article`, load `fontspec` and `xeCJK` explicitly
and use the same `\setCJKmainfont` / `\setCJKsansfont` settings. Do not combine
pdfLaTeX-only CJK recipes with this XeTeX route.

```bash
mkdir -p /tmp/opencode/tex-build
doc-nix tectonic -X compile --keep-logs --outdir /tmp/opencode/tex-build \
  /tmp/opencode/main.tex > /tmp/opencode/tectonic.log 2>&1
render-review /tmp/opencode/tex-build/main.pdf
```

The first compile downloads the TeX bundle and needed resources into Tectonic's
own cache outside the Nix store. Allow minutes in a foreground run. A network
or bundle error needs network/cache diagnosis, not a system TeX installation.
Tectonic handles the reruns needed for cross-references; inspect its final log
for missing glyphs, unresolved references, and overfull boxes. Keep bibliography
inputs alongside the source. Fix technical errors at most three rounds after
the initial attempt, then return the blocker and log to the lead.
