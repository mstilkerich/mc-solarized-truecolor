#!/usr/bin/perl

use strict;
use warnings;
use utf8;

# Match expression for colors in solarized-template.ini
my $mcAccentColorMatch = qr/red|green|yellow|blue|magenta|cyan|orange|violet/;
my $mcColorMatch = qr/\b(?:$mcAccentColorMatch|bgHiInv|bgHi|bgInv|bg|fgUnemph|fgEmph|fgInv|fg)\b/;

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

# Read the template
open(my $TEMPLATEH, '<solarized-template.ini') or die "could not open solarized-template.ini: $!";
my @tmplSkin = <$TEMPLATEH>;
close($TEMPLATEH);

# Open all output files
while (my ($variant, $variantdef) = each (%variants)) {
    while (my ($colortype, $colordef) = each (%{$variantdef->{'colors'}})) {
        my $filename = "solarized-${variant}-$colortype.ini";
        open(my $fh, ">", $filename) or die "could not open $filename: $!";
        $colordef->{'fh'} = $fh;
    }
}

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
                        print {$colordef->{'fh'}} "    $colordef->{'mcColorSetting'}\n";
                    }
                }
            }
        }
        next;
    }

    die "Statement without section: $line" unless defined $section;

    if ($line =~ /(\S+)(\s*=\s*)(($mcColorMatch)(?:;($mcColorMatch)(;reverse)?)?)( *)/) {
        my $lineOutPre = "$`$1$2";
        my $lineOutPost = $';
        my $mcSetting = $1;
        my $wholeMatch = $3;
        my $fgColorSem = $4;
        my $bgColorSem = $5 // '';
        my $reverse = $6 // '';
        my $trailingSpace = $7 // '';

        while (my ($variant, $variantdef) = each (%variants)) {
            my $themeMap = $variantdef->{'themeMap'};

            while (my ($colortype, $colordef) = each (%{$variantdef->{'colors'}})) {
                my $fgColor = mapColor($fgColorSem, $colordef->{'colordefs'}, $themeMap);
                my $bgColor = ($bgColorSem eq '') ? '' : mapColor($bgColorSem, $colordef->{'colordefs'}, $themeMap);

                # reverse makes only sense with ANSI colors, for 256/truecolor we can reverse directly
                if (defined $colordef->{'mcColorSetting'} && $reverse eq ';reverse') {
                    ($fgColor, $bgColor) = ($bgColor, $fgColor);
                }

                my $replacement = $fgColor;
                $replacement .= ";$bgColor" if $bgColor ne '';
                $replacement .= $reverse unless defined $colordef->{'mcColorSetting'};

                my $numSpaces = length($wholeMatch) - length($replacement) + length($trailingSpace);
                my $trailingSpaceNew = ($numSpaces <= 0 || length($trailingSpace) == 0) ? '' : (' ' x $numSpaces);

                print {$colordef->{'fh'}} "$lineOutPre$replacement$trailingSpaceNew$lineOutPost";

                my $colorCombo = "$fgColorSem;$bgColorSem;$reverse";
                $printToTerm{$variant}{$colorCombo}{$colortype} = [ $fgColor, $bgColor, $reverse, $mcSetting ];
            }
        }
    } else {
        if ($section !~ /^(?:lines|widget-|skin)/i) { # ignore sections that contain no color definitions
            print STDERR "No match [$section]: $line";
        }
        printOutLines(\%variants, $line);
    }
}

# Close all output files
while (my ($variant, $variantdef) = each (%variants)) {
    while (my ($colortype, $colordef) = each (%{$variantdef->{'colors'}})) {
        close($colordef->{'fh'});
    }
}

# print color samples to terminal
my @colorTypes = qw(ansi truecolor 256color);
foreach my $variant (sort keys %printToTerm) {
    print "=======================================================================\n";
    print "                                $variant\n";
    print "=======================================================================\n";
    printf "%10.10s%10.10s%20.20s%20.20s\n", "8 colors", "16 colors", "truecolor", "256 colors" ;
    foreach my $colorCombo (sort keys %{$printToTerm{$variant}}) {
        foreach my $colortype (@colorTypes) {
            my $printFn = $variants{$variant}{'colors'}{$colortype}{'colordefs'}{'_printFn'};
            my ($fg, $bg, $rev, $mcSetting) = @{$printToTerm{$variant}{$colorCombo}{$colortype}};
            $printFn->($mcSetting, $fg, $bg, $rev);
        }
        print "\n";
    }
}

exit 0;

sub printOutLines {
    my $variants = shift;
    my @fhs = map { map { $_->{'fh'} } values %{$_->{'colors'}} } values %$variants;

    foreach my $line (@_) {
        foreach my $fh (@fhs) {
            print $fh $line;
        }
    }
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
