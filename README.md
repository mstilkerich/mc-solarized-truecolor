# Solarized skins for midnight commander in ANSI/256-color/truecolor variants

This skin is based on denius/mc-solarized-skin, which uses ANSI colors and requires a customized ANSI color palette in
the terminal configuration. Note that while I used that Skin as a basis, I have adapted the colors so it is not meant to
look the same. For example, the original skin uses light colors for menus in the dark skin variant. I changed it to use
dark colors in the dark skin, light colors in the light skin. I tend to use the dark skin in dim-lit rooms, and in such
cases find it irritating to have larger areas of bright color.

Nowadays, pretty much all terminal emulators support 256-color modes, and even truecolor (16 million colors) is getting
commonly available.

This repository provides solarized skin variants with color definitions from the 256-color palette as well as truecolor
definitions. The upside is that with these skins, you will not have to setup a custom terminal color palette. The 256
color variant is just an approximation as the color palette does not contain the actual colors used by solarized.

## Features

- Themes in color variants for 16-color ANSI terminal, 256 color terminal (approximated colors) and truecolor terminals
- The themes are generated from a common template
- Optionally, adapted syntax files that especially improve syntax highlighting in the internal editor for the light skin

## Installation

Download the release zip file. It contains both the generated theme files as well as the adapted syntax highlight
definitions that you can optionally use.

### Install / select the skin

The skins/ subfolder of the zip file contains the skin files.

- Option 1: Put the skin files in `~/.local/share/mc/skins/`. Select the desired Skin within mc from the Appearances
  option menu.
- Option 2: Put the skin files anywhere you want. Then make the environment variable `MC_SKIN` contain the full path of
  the theme file you want to use.

Option 2 is more flexible, and paritcularly allows to choose between different color variants based on the terminal type
or light / dark variants based on other conditions (e.g. in your shell init file).

### Optional: Install the adapted syntax highlighting file

- Choose the variant matching the selected skin variant and color type from the syntax/ subfolder of the distribution.
- Put this file at `~/.config/mc/mcedit/Syntax`. This will override the system default syntax file.

Unfortunately, it is not possible to set the Syntax file using environment variable or commandline parameter. If you
switch between light and dark skins, you need to make sure to use the proper syntax file, otherwise you will not get
good results (such as hardly readable content).

## Screenshots

More screenshots are available in the subfolder [screenshots](screenshots/README.md).

### Solarized dark (truecolor)
![Dark Variant (Truecolor)](screenshots/dark-truecolor.png)

### Solarized light (truecolor)
![Light Variant (Truecolor)](screenshots/light-truecolor.png)

## Credits

- Ethan Schoonover, creator of [solarized color schemes](https://ethanschoonover.com/solarized/)
- Denis Telnov, whose [mc solarized skin](https://github.com/denius/mc-solarized-skin) these skins are based on

<!-- vim: set ts=4 sw=4 expandtab fenc=utf8 ff=unix tw=120: -->
