#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use Getopt::Long;
use File::Spec;
use File::Path 'make_path';

# Match expression for colors in solarized-template.ini
my $mcAccentColorMatch = qr/red|green|yellow|blue|magenta|cyan|orange|violet/;
my $mcColorMatch = qr/\b(?:$mcAccentColorMatch|bgHiInv|bgHi|bgInv|bg|fgUnemph|fgEmph|fgInv|fg)\b/;
# Match expression for ini-sections that only contain color definitions
# Die if our color match expression does not match a line in these sections
my $mcColorSectMatch =
    qr/^(core|popupmenu|dialog|diffviewer|error|filehighlight|menu|statusbar|help|buttonbar|editor|viewer)$/;

# solarized mappings from
# https://ethanschoonover.com/solarized/
my %solarized16M = (
    'base03'  => '#002b36', # brblack
    'base02'  => '#073642', # black
    'base01'  => '#586e75', # brgreen
    'base00'  => '#657b83', # bryellow
    'base0'   => '#839496', # brblue
    'base1'   => '#93a1a1', # brcyan
    'base2'   => '#eee8d5', # white
    'base3'   => '#fdf6e3', # brwhite
    'yellow'  => '#b58900', # yellow
    'orange'  => '#cb4b16', # brred
    'red'     => '#dc322f', # red
    'magenta' => '#d33682', # magenta
    'violet'  => '#6c71c4', # brmagenta
    'blue'    => '#268bd2', # blue
    'cyan'    => '#2aa198', # cyan
    'green'   => '#859900', # green

    '_printFn' => sub {
        my ($text, $fgColor, $bgColor, $reverse) = @_;

        $fgColor =~ /^#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/i or die "no valid RGB color $fgColor";
        printf "\e[38;2;%d;%d;%dm", hex($1), hex($2), hex($3);
        if ($bgColor ne '') {
            $bgColor =~ /^#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/i or die "no valid RGB color $bgColor";
            printf "\e[48;2;%d;%d;%dm", hex($1), hex($2), hex($3);
        }

        printf "%20.20s\e[0m", $text;
    },
);

my %solarized256 = (
    'base03'  => 'color234', # brblack
    'base02'  => 'color235', # black
    'base01'  => 'color240', # brgreen
    'base00'  => 'color241', # bryellow
    'base0'   => 'color244', # brblue
    'base1'   => 'color245', # brcyan
    'base2'   => 'color254', # white
    'base3'   => 'color230', # brwhite
    'yellow'  => 'color136', # yellow
    'orange'  => 'color166', # brred
    'red'     => 'color160', # red
    'magenta' => 'color125', # magenta
    'violet'  =>  'color61', # brmagenta
    'blue'    =>  'color33', # blue
    'cyan'    =>  'color37', # cyan
    'green'   =>  'color64', # green

    '_printFn' => sub {
        my ($text, $fgColor, $bgColor, $reverse) = @_;

        $fgColor =~ /^color(\d+)$/i or die "no valid 256-palette color $fgColor";
        printf "\e[38;5;%dm", $1;
        if ($bgColor ne '') {
            $bgColor =~ /^color(\d+)$/i or die "no valid 256-palette color $bgColor";
            printf "\e[48;5;%dm", $1;
        }

        printf "%20.20s\e[0m", $text;
    },
);

# this maps the solarized colors to the ANSI color names used by midnight commander
# mc colors from: https://midnight-commander.org/wiki/doc/common/skins
# mappings to ANSI colors from: https://github.com/MidnightCommander/mc/blob/master/lib/tty/color-internal.c
my %solarized16 = (
    'base03'  => 'gray', # brblack
    'base02'  => 'black', # black
    'base01'  => 'brightgreen', # brgreen
    'base00'  => 'yellow', # bryellow
    'base0'   => 'brightblue', # brblue
    'base1'   => 'brightcyan', # brcyan
    'base2'   => 'lightgray', # white
    'base3'   => 'white', # brwhite
    'yellow'  => 'brown', # yellow
    'orange'  => 'brightred', # brred
    'red'     => 'red', # red
    'magenta' => 'magenta', # magenta
    'violet'  => 'brightmagenta', # brmagenta
    'blue'    => 'blue', # blue
    'cyan'    => 'cyan', # cyan
    'green'   => 'green', # green

    '_printFn' => sub {
        my ($text, $fgColor, $bgColor, $reverse) = @_;
        my %colornum = (
            'black'         =>  0,
            'red'           =>  1,
            'green'         =>  2,
            'brown'         =>  3,
            'blue'          =>  4,
            'magenta'       =>  5,
            'cyan'          =>  6,
            'lightgray'     =>  7,
            'gray'          =>  8,
            'brightred'     =>  9,
            'brightgreen'   => 10,
            'yellow'        => 11,
            'brightblue'    => 12,
            'brightmagenta' => 13,
            'brightcyan'    => 14,
            'white'         => 15,
        );

        die "no valid ansi color $fgColor" unless defined $colornum{$fgColor};
        $fgColor = $colornum{$fgColor};
        if ($bgColor ne '') {
            die "no valid ansi color $bgColor" unless defined $colornum{$bgColor};
            $bgColor = $colornum{$bgColor};
        }
        $reverse = $reverse ? '7;' : '';

        # using bold attribute for bright colors
        printf "\e[%s%s%dm", $reverse, ($fgColor > 7 ? '1;' : ''), ($fgColor > 7 ? (30+$fgColor-8) : (30+$fgColor));
        my $colorErr = '';
        if ($bgColor ne '') {
            printf "\e[%dm", ($bgColor > 7 ? (40+$bgColor-8) : (40+$bgColor));
            if ($bgColor > 7) {
                $colorErr = $fgColor > 7 ? '!' : '~';
            }
        }
        printf "%10.10s\e[0m", $colorErr.$text;

        # using 16-color aixterm codes
        printf "\e[%s%dm", $reverse, ($fgColor > 7 ? (90+$fgColor-8) : (30+$fgColor));
        if ($bgColor ne '') {
            printf "\e[%dm", ($bgColor > 7 ? (100+$bgColor-8) : (40+$bgColor));
        }
        printf "%10.10s\e[0m", $text;
    },
);

my %solarizedCommon = map { $_ => $_ } qw(red green yellow blue magenta cyan orange violet);

my %solarizedDark = (
    '_desc'         => 'solarized dark',
    %solarizedCommon,
    'bg'       => 'base03',
    'bgInv'    => 'base3',
    'bgHi'     => 'base02',
    'bgHiInv'  => 'base2',
    'fg'       => 'base0',
    'fgInv'    => 'base00',
    'fgEmph'   => 'base1',
    'fgUnemph' => 'base01',
);

my %solarizedLight = (
    '_desc'         => 'solarized light',
    %solarizedCommon,
    'bg'       => 'base3',
    'bgInv'    => 'base03',
    'bgHi'     => 'base2',
    'bgHiInv'  => 'base02',
    'fg'       => 'base00',
    'fgInv'    => 'base0',
    'fgEmph'   => 'base01',
    'fgUnemph' => 'base1',
);

my %variants = (
    'dark' => {
        'themeMap' => \%solarizedDark,
        'colors' => {
            'truecolor' => {
                'colordefs' => \%solarized16M,
                'mcColorSetting' => 'truecolors = true',
            },
            '256color' => {
                'colordefs' => \%solarized256,
                'mcColorSetting' => '256colors = true',
            },
            'ansi' => {
                'colordefs' => \%solarized16,
                'mcColorSetting' => undef,
            },
        }
    },

    'light' => {
        'themeMap' => \%solarizedLight,
        'colors' => {
            'truecolor' => {
                'colordefs' => \%solarized16M,
                'mcColorSetting' => 'truecolors = true',
            },
            '256color' => {
                'colordefs' => \%solarized256,
                'mcColorSetting' => '256colors = true',
            },
            'ansi' => {
                'colordefs' => \%solarized16,
                'mcColorSetting' => undef,
            },
        },
    }
);

my %synMapFg = (
    'default' => 'fg', # special value default: terminal default color
    'base' => 'fg', # special value base: mc main colors from skin core._default_
    'blue' => 'blue',
    'brightmagenta' => 'violet',
    'brightred' => 'orange',
    'cyan' => 'cyan',
    'green' => 'green',
    'magenta' => 'magenta',
    'red' => 'red',
    'brown' => 'yellow',

    'black' => 'bgHi', # base02
    'brightgreen' => 'fgUnemph', # base01
    'yellow' => 'fgInv', # base00
    'brightblue' => 'fg', # base0
    'brightcyan' => 'fgEmph', # base1
    'lightgray' => 'bgHiInv', # base2
    'white' => 'bgInv', # base3

    # Gray is used as foreground highlight for some syntax items. In the default MC Skin, the background is blue.
    # With solarized, the default mapping would result in equal foreground and background -> we need to provide a
    # different mapping.
    'gray' => 'blue', # base03
);
my %synMapBg = (
    'default' => 'bg', # special value default: terminal default color
    'base' => 'bg', # special value base: mc main colors from skin core._default_
    'blue' => 'blue',
    'brightmagenta' => 'violet',
    'brightred' => 'orange',
    'cyan' => 'cyan',
    'green' => 'green',
    'magenta' => 'magenta',
    'red' => 'red',
    'brown' => 'yellow',

    'gray' => 'bg', # base03
    'black' => 'bgHi', # base02
    'brightgreen' => 'fgUnemph', # base01
    'yellow' => 'fgInv', # base00
    'brightblue' => 'fg', # base0
    'brightcyan' => 'fgEmph', # base1
    'lightgray' => 'bgHiInv', # base2
    'white' => 'bgInv', # base3
);

# Get commandline options
my $syntaxFile;
my $printColors;
my $contrastLimit;
my $version;
GetOptions(
    "syntaxfile=s" => \$syntaxFile,
    "contrastlimit=f" => \$contrastLimit,
    "printcolors" => \$printColors,
    "version=s" => \$version,
) or die("Error in command line arguments\n");

$version //= `git rev-parse HEAD`;
chomp $version;

# Read the template
open(my $TEMPLATEH, '<solarized-template.ini') or die "could not open solarized-template.ini: $!";
my @tmplSkin = <$TEMPLATEH>;
close($TEMPLATEH);

# Open all output files
-d 'build/skins' or make_path('build/skins') or die 'could not create directory build/skins';
openOutFiles('build/skins/solarized-');

my $section = undef;
my %printToTerm = ();
foreach my $line (@tmplSkin) {
    # pass through comment or whitespace line
    if (($line =~ /^\s*$/) || ($line =~ /^\s*#/)) {
        printOutLines(\%variants, $line);
        next;
    }

    # start of section
    if ($line =~ /^\s*\[(\S+)\]\s*$/i) {
        $section = $1;

        printOutLines(\%variants, $line);
        if ($section =~ /^skin$/i) {
            while (my ($variant, $variantdef) = each (%variants)) {
                while (my ($colortype, $colordef) = each (%{$variantdef->{'colors'}})) {
                    if (defined $colordef->{'mcColorSetting'}) {
                        print {$colordef->{'fh'}} "$colordef->{'mcColorSetting'}\n";
                    }
                }
            }
        }
        next;
    }

    die "Statement without section: $line" unless defined $section;

    if ($line =~ /(\S+)(\s*=\s*)(($mcColorMatch)(?:;($mcColorMatch);?(reverse(?:\+(\S+))?)?)?)/) {
        my $lineOutPre = "$`$1$2";
        my $lineOutPost = $';
        my $mcSetting = $1;
        my $wholeMatch = $3;
        my $fgColorSem = $4;
        my $bgColorSem = $5 // '';
        my $reverse = $6 // '';
        my $otherattr = $7 // '';

        while (my ($variant, $variantdef) = each (%variants)) {
            my $themeMap = $variantdef->{'themeMap'};

            while (my ($colortype, $colordef) = each (%{$variantdef->{'colors'}})) {
                my $fgColor = mapColor($fgColorSem, $colordef->{'colordefs'}, $themeMap);
                my $bgColor = ($bgColorSem eq '') ? '' : mapColor($bgColorSem, $colordef->{'colordefs'}, $themeMap);

                # reverse makes only sense with ANSI colors, for 256/truecolor we can reverse directly
                if (defined $colordef->{'mcColorSetting'} && $reverse) {
                    ($fgColor, $bgColor) = ($bgColor, $fgColor);
                }

                my $replacement = "$fgColor;";
                $replacement .= "$bgColor;";
                $replacement .= $reverse unless defined $colordef->{'mcColorSetting'};
                $replacement .= $otherattr;

                print {$colordef->{'fh'}} "$lineOutPre$replacement$lineOutPost";

                my $colorCombo = "$fgColorSem;$bgColorSem;$reverse";
                if ($colortype eq 'truecolor') {
                    my $bgColorForContrast = $bgColor || mapColor('bg', $colordef->{'colordefs'}, $themeMap);
                    $printToTerm{$variant}{$colorCombo}{'contrast'} = contrastRatioRGB($fgColor, $bgColorForContrast);
                }
                $printToTerm{$variant}{$colorCombo}{$colortype} = [ $fgColor, $bgColor, $reverse, $mcSetting ];
            }
        }
    } elsif ($section eq 'skin' && $line =~ /^\s*description\s*=/)  {
        printInfoLine(\%variants, $line);
    } else {
        die "No match [$section]: $line" if $section =~ /$mcColorSectMatch/;
        printOutLines(\%variants, $line);
    }
}

# Close all output files
closeOutFiles();

printColorSamples('Skin colors', \%printToTerm) if $printColors;
%printToTerm = ();

if (defined ($syntaxFile)) {
    mapSyntaxFiles($syntaxFile);
    printColorSamples('Syntax colors', \%printToTerm) if $printColors;
    %printToTerm = ();
}

exit 0;

sub printColorSamples {
    my ($themedItem, $printToTerm) = @_;

    # print color samples to terminal
    my @colorTypes = qw(ansi truecolor 256color);
    foreach my $variant (sort keys %$printToTerm) {
        print "=======================================================================\n";
        print "                         $themedItem: $variant\n";
        print "-----------------------------------------------------------------------\n";
        printf "%10.10s%10.10s%20.20s%20.20s %s\n", "8 colors", "16 colors", "truecolor", "256 colors", "contrast";
        foreach my $colorCombo (sort keys %{$printToTerm->{$variant}}) {
            my $cratio = $printToTerm->{$variant}{$colorCombo}{'contrast'};
            next if defined $contrastLimit && $contrastLimit < $cratio;

            foreach my $colortype (@colorTypes) {
                my $printFn = $variants{$variant}{'colors'}{$colortype}{'colordefs'}{'_printFn'};
                my ($fg, $bg, $rev, $mcSetting) = @{$printToTerm->{$variant}{$colorCombo}{$colortype}};
                $printFn->($mcSetting, $fg, $bg, $rev);
            }
            printf(" %8.1f\n", $cratio);

            if (defined $contrastLimit && $cratio < $contrastLimit) {
                print "COLOR COMBO $colorCombo\n";
                foreach my $line (@{$printToTerm->{$variant}{$colorCombo}{'lines'}}) {
                    print "$line\n";
                }
            }
        }
    }
}

# Maps the syntax highlight definitions of midnight commander to solarized variants
# The original file consists of one master file which includes individual syntax files, one per filetype
# The output here inlines all the included files, so we get one single output file per theme variant(light/dark) and
# color type (truecolor, etc.). This allows easier handling than a full set of files.
#
# The function attempts to map back the midnight commander colors in the syntax files to semantic colors, such that we
# get readable results for both light and dark skin variants, plus we can benefit from having RGB colors in the
# truecolor variant that are independent on the configured terminal color palette.
#
sub mapSyntaxFiles {
    my ($synFile) = @_;
    my @lines = readFile($synFile);
    my (undef, $synBaseDir) = File::Spec->splitpath($synFile);

    $synBaseDir = '.' unless $synBaseDir ne '';

    -d 'build/syntax' or mkdir('build/syntax') or die 'could not create directory build/syntax: $!';
    # open out files
    openOutFiles('build/syntax/');

    # print Info Line
    printInfoLine(
        \%variants,
        "# Adapted syntax definitions for solarized \$VARIANT skin (\$COLORTYPE, Version \$VERSION)\n",
        "# See https://github.com/mstilkerich/mc-solarized-truecolor\n",
        "\n",
    );

    # process lines
    my @context; # ( foreground, background ) of current context, undefined outside context
    my %defines = (
        # workarounds for issues in mc syntax files
        'grey' => 'gray',
        'lightgrey' => 'lightgray',
        'string' => 'strings',
    );

    while (my $line = shift @lines) {
        if ($line =~ /^\s*include\s+(\S+)/ ) {
            my @includeLines = readFile("$synBaseDir/$1");
            unshift @lines, "# $line\n", @includeLines;
        } elsif ($line =~ /^\s*define\s+(\S+)\s+(\S+)/) {
            $defines{$1} = $2;

            # we could also omit the define from the generated file
            printOutLines(\%variants, $line);
        } elsif (
            # keyword [whole|wholeright|wholeleft] [linestart] string foreground [background] [attributes]
            ($line =~ /^(?<linestart>\s*(?<type>keyword)\s+(?:(?:whole|wholeright|wholeleft)\s+)?+(?:linestart\s+)?+\S+\s+)(?<fg>\S+)(?:\s+(?<bg>\S+))?(?:\s+(?<attr>\S+))?(?<lineend>.*)/) ||
            # context default [foreground] [background] [attributes]
            ($line =~ /^(?<linestart>\s*(?<type>context)\s+default)(?:\s+(?<fg>\S+))?(?:\s+(?<bg>\S+))?(?:\s+(?<attr>\S+))?(?<lineend>.*)/) ||
            # context [exclusive] [whole|wholeright|wholeleft] [linestart] delim [linestart] delim [foreground] [background] [attributes]
            ($line =~ /^(?<linestart>\s*(?<type>context)\s+(?:exclusive\s+)?+(?:(?:whole|wholeright|wholeleft)\s+)?+(?:linestart\s+)?+\S+\s+(?:linestart\s+)?+\S+)(?:\s+(?<fg>\S+))?(?:\s+(?<bg>\S+))?(?:\s+(?<attr>\S+))?(?<lineend>.*)/)
        ) {
            my $type = $+{'type'}; # context or keyword
            my $fg   = $+{'fg'} // '';
            my $bg   = $+{'bg'} // '';
            my $attr = $+{'attr'} // '';
            my $linestart = $+{'linestart'};
            my $lineend = $+{'lineend'};

            # strip cooledit color if present (colors may be specified as mcColor/cooleditColor)
            $fg =~ s,/.*,,;
            $bg =~ s,/.*,,;

            # resolve defines
            my $fgColorSem = resolveDefine(\%defines, $fg);
            my $bgColorSem = resolveDefine(\%defines, $bg);
            $attr = resolveDefine(\%defines, $attr);

            # determine actually used colors from context and defaults
            if ($type eq 'context') {
                $fgColorSem = 'default' if $fgColorSem eq '';
                $bgColorSem = 'default' if $bgColorSem eq '';

                @context = ( $fgColorSem, $bgColorSem );
            } else {
                die "Keyword without context: $line" unless @context;
                $fgColorSem = $context[0] if $fgColorSem eq '';
                $bgColorSem = $context[1] if $bgColorSem eq '';
            }

            $fgColorSem = reverseMapColor($fgColorSem, \%synMapFg);
            $bgColorSem = reverseMapColor($bgColorSem, \%synMapBg);

            while (my ($variant, $variantdef) = each (%variants)) {
                my $themeMap = $variantdef->{'themeMap'};

                while (my ($colortype, $colordef) = each (%{$variantdef->{'colors'}})) {
                    my $fgColor = mapColor($fgColorSem, $colordef->{'colordefs'}, $themeMap);
                    my $bgColor = mapColor($bgColorSem, $colordef->{'colordefs'}, $themeMap);

                    my $colorCombo = "$fgColorSem;$bgColorSem;$attr";

                    my $lineChomp = $line;
                    chomp($lineChomp);
                    $lineChomp =~ s/\t/ /g;
                    $printToTerm{$variant}{$colorCombo}{$colortype} = [ $fgColor, $bgColor, '', $lineChomp ];
                    if ($colortype eq 'truecolor') {
                        my $cratio = contrastRatioRGB($fgColor, $bgColor);
                        $printToTerm{$variant}{$colorCombo}{'contrast'} = $cratio;
                        $printToTerm{$variant}{$colorCombo}{'lines'} //= [];
                        push @{$printToTerm{$variant}{$colorCombo}{'lines'}}, $lineChomp;
                    }

                    my $replacement = " $fgColor";
                    $replacement .= " $bgColor " if $bg ne '';
                    $replacement .= " $attr" if $attr ne '';

                    print {$colordef->{'fh'}} "$linestart$replacement$lineend\n";
                }
            }
        } else {
            # line output unmodified

            die $line if $line =~ /^\s*context/;
            if ($line =~ /^\s*file\s/) {
                @context = ();
            }

            printOutLines(\%variants, $line);
        }
    }

    # close output files
    closeOutFiles();
}

# Resolves a color alias in a midnight commander syntax file using the "define" primitive in the syntax file
# The result should be a midnight commander color
sub resolveDefine {
    my ($defines, $alias) = @_;

    # create a copy so we can modify the hash here
    my %defines = %$defines;
    while (exists $defines{$alias}) {
        $alias = delete $defines{$alias};
    }

    return $alias;
}

# opens all variant ini files and stores the file handles to be used with printOutLines()
sub openOutFiles {
    my ($prefix) = @_;

    while (my ($variant, $variantdef) = each (%variants)) {
        while (my ($colortype, $colordef) = each (%{$variantdef->{'colors'}})) {
            my $filename = "${prefix}${variant}-$colortype.ini";
            open(my $fh, ">", $filename) or die "could not open $filename: $!";
            $colordef->{'fh'} = $fh;
        }
    }
}

# Prints a line to all open variant ini files; openOutFiles() must be called first
sub printOutLines {
    my $variants = shift;
    my @fhs = map { map { $_->{'fh'} } values %{$_->{'colors'}} } values %$variants;

    foreach my $line (@_) {
        foreach my $fh (@fhs) {
            print $fh $line;
        }
    }
}

# Prints an info line to all open variant ini files; openOutFiles() must be called first
# In the info line, the placeholders $VERSION, $VARIANT and $COLORTYPE are replaced
sub printInfoLine {
    my $variants = shift;

    while (my ($variant, $variantdef) = each (%variants)) {
        while (my ($colortype, $colordef) = each (%{$variantdef->{'colors'}})) {
            foreach my $line (@_) {
                my $l = $line;
                $l =~ s/\$VERSION/$version/g;
                $l =~ s/\$VARIANT/$variant/g;
                $l =~ s/\$COLORTYPE/$colortype/g;

                my $fh = $colordef->{'fh'};
                print $fh $l;
            }
        }
    }
}

# closes all open variant ini files
sub closeOutFiles {
    while (my ($variant, $variantdef) = each (%variants)) {
        while (my ($colortype, $colordef) = each (%{$variantdef->{'colors'}})) {
            close($colordef->{'fh'});
            delete $colordef->{'fh'};
        }
    }
}

# Reads in a file and returns its content as an array of lines
sub readFile {
    my ($file) = @_;
    open (my $FH, '<', $file) or die "failed to open $file: $!";
    my @lines = <$FH>;
    close($FH);
    return @lines;
}

# Maps a semantic color as used in the skin (e.g., fg, bg) to a midnight commander color in the given color type (ansi,
# truecolor, 256color) and skin variant (light, dark)
sub mapColor {
    my ($tmplColor, $colordefs, $themeMap) = @_;

    my $solColor = $themeMap->{$tmplColor} // undef;
    if ($solColor) {
        die "Unknown solarized color: $solColor" unless defined $colordefs->{$solColor};
        return $colordefs->{$solColor};
    } else {
        die "Use of unsupported color $tmplColor in scheme $themeMap->{'_desc'}";
    }
}

# Maps a (midnight commander) color from a syntax file back to a sementic color as used in the skin template
sub reverseMapColor {
    my ($color, $synMap) = @_;

    if (exists $synMap->{$color}) {
        return $synMap->{$color};
    }

    die "No reverse mapping for color $color";
}

# Computes the contrast ratio of two RGB colors given in #RRGGBB format
# Taken from: https://www.w3.org/TR/WCAG20/
sub contrastRatioRGB {
    # ( [R1, G1, B1], [R2, G2, B2] )
    my @lumComponents = map {
        /^#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/i or die "invalid RGB color $_";
        [ map { relativeLuminanceComponent(hex($_)) } ($1, $2, $3) ]
    } @_;

    my ($relLum1, $relLum2) = map {
        my ($R, $G, $B) = @$_;
        0.2126 * $R + 0.7152 * $G + 0.0722 * $B
    } @lumComponents;

    # make sure relLum1 is the lighter of the two colors
    if ($relLum1 < $relLum2) {
        ($relLum1, $relLum2) = ($relLum2, $relLum1);
    }

    my $contrastRatio = ($relLum1 + 0.05) / ($relLum2 + 0.05);
    return $contrastRatio;
}

sub relativeLuminanceComponent {
    my $c = shift; # 0 - 255
    $c = $c/255;

    if ($c < 0.03928) {
        return $c / 12.92;
    } else {
        return (($c+0.055)/1.055) ** 2.4;
    }
}

# vim: ts=4:sw=4:expandtab:fenc=utf8:ff=unix:tw=120
