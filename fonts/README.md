# Fonts

Fonts that Homebrew doesn't carry, or that I also need as `.woff2` for web projects
(`fonts.txt` covers the Homebrew ones). One folder per font, holding whatever formats
exist for it:

- `.ttf` / `.otf`: what the installers put in the user font folder on every OS
  (`~/Library/Fonts`, `%LOCALAPPDATA%\Microsoft\Windows\Fonts`, `~/.local/share/fonts`).
  The folder is the manifest; nothing to list.
- `.woff2`: the web format, for `@font-face` in a site (browsers don't use the desktop
  formats and desktops don't use this one). Reference it from a project as
  `~/dotfiles/fonts/<Font>/<file>.woff2` or copy it into the site's fonts folder.
- `LICENSE`: the font's license. Only fonts whose license allows redistribution go here.

## Excalifont

Excalidraw's hand-drawn font (https://plus.excalidraw.com/excalifont), SIL Open Font
License 1.1. Excalidraw publishes only the `.woff2`; the `.ttf` is that file converted
with `woff2_decompress` (from the `woff2` package), byte-for-byte what a desktop needs.
