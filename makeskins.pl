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

# mc colors from
# https://midnight-commander.org/wiki/doc/common/skins
# mappings to ANSI colors from
# https://github.com/MidnightCommander/mc/blob/master/lib/tty/color-internal.c
my %mc2solarizedDark = (
    '_desc'         => 'solarized dark',
    'black'         => 'base02',
    'red'           => 'red',
    'green'         => 'green',
    'brown'         => 'yellow',
    'blue'          => 'blue',
    'magenta'       => 'magenta',
    'cyan'          => 'cyan',
    'lightgray'     => 'base2',
    'gray'          => 'base03',
    'brightred'     => 'orange',
    'brightgreen'   => 'base01',
    'yellow'        => 'base00',
    'brightblue'    => 'base0',
    'brightmagenta' => 'violet',
    'brightcyan'    => 'base1',
    'white'         => 'base3',
);

my %variants = (
    'dark-truecolor' => [ \%solarized16M, \%mc2solarizedDark, 'truecolors = true' ],
    'dark-256color'  => [ \%solarized256, \%mc2solarizedDark, '256colors = true' ],
);

open(my $ANSIH, '<solarized-dark-ansi.ini') or die "could not open solarized-dark-ansi.ini: $!";
my @ansiSkin = <$ANSIH>;
close($ANSIH);

my $mcBrColorMatch = qr/blue|cyan|green|magenta|red/;
my $mcColorMatch = qr/(?:bright(?:$mcBrColorMatch)|black|brown|(?:light)?gray|white|yellow|$mcBrColorMatch)/;
foreach my $variant (keys %variants) {
    my ($colordefs, $mcmap, $mcColorSetting) = @{$variants{$variant}};

    open (my $OUTH, ">solarized-$variant.ini") or die "could not open solarized-$variant.ini: $!";

    my $section = undef;

    foreach my $line (@ansiSkin) {
        # pass through comment or whitespace line
        if (($line =~ /^\s*$/) || ($line =~ /^\s*#/)) {
            print $OUTH $line;
            next;
        }

        # start of section
        if ($line =~ /^\s*\[(\S+)\]\s*$/i) {
            $section = $1;

            print $OUTH $line;
            if ($section =~ /skin/i) {
                print $OUTH "    $mcColorSetting\n";
            }
            next;
        }

        die "Statement without section: $line" unless defined $section;

        if ($line =~ /(=\s*)(($mcColorMatch)(?:;($mcColorMatch)(;reverse)?)?)(\s*)/) {
            my $lineOutPre = "$`$1";
            my $lineOutPost = $';
            my $wholeMatch = $2;
            my $fgColor = $3;
            my $bgColor = $4 // '';
            my $reverse = $5 // '';
            my $trailingSpace = $6 // '';

            $fgColor = mapColor($fgColor, $colordefs, $mcmap);
            if ($bgColor ne '') {
                $bgColor = mapColor($bgColor, $colordefs, $mcmap);
            }

            # reverse makes only sense with ANSI colors, for 256/truecolor we can reverse directly
            if ($reverse eq ';reverse') {
                ($fgColor, $bgColor) = ($bgColor, $fgColor);
            }

            my $replacement = $fgColor;
            $replacement .= ";$bgColor" if $bgColor ne '';

            my $numSpaces = length($wholeMatch) - length($replacement) + length($trailingSpace);
            $trailingSpace = ($numSpaces <= 0) ? '' : (' ' x $numSpaces);

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
    my ($mccolor, $colordefs, $mcmap) = @_;

    my $solColor = $mcmap->{$mccolor} // undef;
    if ($solColor) {
        die unless defined $colordefs->{$solColor};
        return $colordefs->{$solColor};
    } else {
        die "Use of unsupported color $mccolor in scheme $mcmap->{'_desc'}";
    }
}

# vim: ts=4:sw=4:expandtab:fenc=utf8:ff=unix:tw=120
