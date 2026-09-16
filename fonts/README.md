# Fonts

The fonts I use, in the formats I need them in: the desktop formats for fonts Homebrew
doesn't carry, and `.woff2` for every family so web projects can pull from here (search
this folder for `.woff2` and those are my preferred web fonts). One folder per font,
holding whatever formats apply:

- `.ttf` / `.otf`: what the installers put in the user font folder on every OS
  (`~/Library/Fonts`, `%LOCALAPPDATA%\Microsoft\Windows\Fonts`, `~/.local/share/fonts`).
  The folder is the manifest; nothing to list.
- `.woff2`: the web format, for `@font-face` in a site (browsers don't use the desktop
  formats and desktops don't use this one). Reference it from a project as
  `~/dotfiles/fonts/<Font>/<file>.woff2` or copy it into the site's fonts folder.
- `LICENSE`: the font's license. Only fonts whose license allows redistribution go here.

## The Homebrew families (`.woff2` only)

Every family in `fonts.txt` has a folder here with `.woff2` versions of the files Homebrew
installs (converted once with `woff2_compress`; variable fonts where the family has them,
otherwise the static weights) and the family's license. No desktop files: those come from
`fonts.txt` on the Mac and `windows/fonts.ps1` on Windows, so the installers ignore these
folders. To refresh after a family changes upstream: `woff2_compress <file>.ttf`, move the
result here.

## Excalifont

Excalidraw's hand-drawn font (https://plus.excalidraw.com/excalifont), SIL Open Font
License 1.1. Excalidraw publishes only the `.woff2`; the `.ttf` is that file converted
with `woff2_decompress` (from the `woff2` package), byte-for-byte what a desktop needs.
