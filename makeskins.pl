#!/usr/bin/perl

use strict;
use warnings;
use utf8;

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
    'dark-truecolor'  => [ \%solarized16M, \%solarizedDark,  'truecolors = true' ],
    'dark-256color'   => [ \%solarized256, \%solarizedDark,  '256colors = true' ],
    'dark-ansi'       => [ \%solarized16,  \%solarizedDark,  undef ],
    'light-truecolor' => [ \%solarized16M, \%solarizedLight, 'truecolors = true' ],
    'light-256color'  => [ \%solarized256, \%solarizedLight, '256colors = true' ],
    'light-ansi'      => [ \%solarized16,  \%solarizedLight, undef ],
);

open(my $TEMPLATEH, '<solarized-template.ini') or die "could not open solarized-template.ini: $!";
my @tmplSkin = <$TEMPLATEH>;
close($TEMPLATEH);

my $mcAccentColorMatch = qr/red|green|yellow|blue|magenta|cyan|orange|violet/;
my $mcColorMatch = qr/\b(?:$mcAccentColorMatch|bgHiInv|bgHi|bgInv|bg|fgUnemph|fgEmph|fgInv|fg)\b/;

foreach my $variant (keys %variants) {
    my ($colordefs, $themeMap, $mcColorSetting) = @{$variants{$variant}};

    open (my $OUTH, ">solarized-$variant.ini") or die "could not open solarized-$variant.ini: $!";

    my $section = undef;

    foreach my $line (@tmplSkin) {
        # pass through comment or whitespace line
        if (($line =~ /^\s*$/) || ($line =~ /^\s*#/)) {
            print $OUTH $line;
            next;
        }

        # start of section
        if ($line =~ /^\s*\[(\S+)\]\s*$/i) {
            $section = $1;

            print $OUTH $line;
            if (defined $mcColorSetting && $section =~ /^skin$/i) {
                print $OUTH "    $mcColorSetting\n";
            }
            next;
        }

        die "Statement without section: $line" unless defined $section;

        if ($line =~ /(=\s*)(($mcColorMatch)(?:;($mcColorMatch)(;reverse)?)?)( *)/) {
            my $lineOutPre = "$`$1";
            my $lineOutPost = $';
            my $wholeMatch = $2;
            my $fgColor = $3;
            my $bgColor = $4 // '';
            my $reverse = $5 // '';
            my $trailingSpace = $6 // '';

            $fgColor = mapColor($fgColor, $colordefs, $themeMap);
            if ($bgColor ne '') {
                $bgColor = mapColor($bgColor, $colordefs, $themeMap);
            }

            # reverse makes only sense with ANSI colors, for 256/truecolor we can reverse directly
            if (defined $mcColorSetting && $reverse eq ';reverse') {
                ($fgColor, $bgColor) = ($bgColor, $fgColor);
            }

            my $replacement = $fgColor;
            $replacement .= ";$bgColor" if $bgColor ne '';
            $replacement .= $reverse unless defined $mcColorSetting;

            my $numSpaces = length($wholeMatch) - length($replacement) + length($trailingSpace);
            $trailingSpace = ($numSpaces <= 0 || length($trailingSpace) == 0) ? '' : (' ' x $numSpaces);

            print $OUTH "$lineOutPre$replacement$trailingSpace$lineOutPost";
        } else {
            if ($section !~ /^(?:lines|widget-|skin)/i) { # ignore sections that contain no color definitions
                print STDERR "No match [$section]: $line";
            }
            print $OUTH $line;
        }
    }

    close ($OUTH);
}

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

# vim: ts=4:sw=4:expandtab:fenc=utf8:ff=unix:tw=120
