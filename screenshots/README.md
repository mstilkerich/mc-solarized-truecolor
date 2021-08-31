# Main Panel
## Solarized dark (truecolor)
![Main Panel - Dark Variant (Truecolor)](dark-truecolor.png)
## Solarized light (truecolor)
![Main Panel - Light Variant (Truecolor)](light-truecolor.png)

# Help Viewer
## Solarized dark (truecolor)
![Help Viewer - Dark Variant (Truecolor)](dark-truecolor-help.png)
## Solarized light (truecolor)
![Help Viewer - Light Variant (Truecolor)](light-truecolor-help.png)

# Internal Viewer
## Solarized dark (truecolor)
![Internal Viewer - Dark Variant (Truecolor)](dark-truecolor-internalviewer.png)
## Solarized light (truecolor)
![Internal Viewer - Light Variant (Truecolor)](light-truecolor-internalviewer.png)

# Internal Editor

There is a big caveat about the internal editor: syntax highlighting is not customizable by skins. Secondly, the syntax
files shipped with midnight commander use ANSI colors, so unless you configured your terminal to use the solarized color
palette for the 16 standard colors, the colors used for syntax-highlighted elements might not be from the solarized
palette at all.

Besides the non-deterministic colors resulting from the use of ANSI colors, the worst thing about the inability to
customize the syntax highlighting is that some of the colors are barely readable depending on the background used by the
skin. You can see this in the below screenshots in the light variant for the window that shows README.md. The markdown
syntax highlighting uses "lightgray" as the text color, which is ANSI color "white". In solarized light, this color is
used for the emphasized background. Used as foreground color on the standard solarized light background, it is barely
readable.

In the dark variant, the colors seem to work better but there may be problems with some filetypes as well that I did not
encounter yet.

## Solarized dark (truecolor)
![Internal Editor - Dark Variant (Truecolor)](dark-truecolor-editor.png)
## Solarized light (truecolor)
![Internal Editor - Light Variant (Truecolor)](light-truecolor-editor.png)

# History Dialog
Highlighted entries of the history dialog unfortunately use the color of focused hotkeys. This does fit the theme, but
cannot be avoided currently. See [ticket](https://midnight-commander.org/ticket/3160).

## Solarized dark (truecolor)
![Dark Variant (Truecolor)](dark-truecolor-history-dialog.png)

<!-- vim: set ts=4 sw=4 expandtab fenc=utf8 ff=unix tw=120: -->
