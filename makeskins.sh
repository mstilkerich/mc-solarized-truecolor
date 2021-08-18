#!/bin/sh

# This script creates the midnight commander themes in 256 color and truecolor variants from the ANSI variant

#wget -O solarized-dark-ansi.ini https://raw.githubusercontent.com/denius/mc-solarized-skin/master/solarized.ini

base03='#002b36' # brblack  
base02='#073642' # black    
base01='#586e75' # brgreen  
base00='#657b83' # bryellow 
base0='#839496' # brblue   
base1='#93a1a1' # brcyan   
base2='#eee8d5' # white    
base3='#fdf6e3' # brwhite  
yellow='#b58900' # yellow   
orange='#cb4b16' # brred    
red='#dc322f' # red      
magenta='#d33682' # magenta  
violet='#6c71c4' # brmagenta
blue='#268bd2' # blue     
cyan='#2aa198' # cyan     
green='#859900' # green    


sed \
	-e '/\[skin\]/a\
	truecolors = true' \
	-e "s/blueblack/$blue/g" \
	-e "s/lightgray/$base2/g" \
	-e "s/brightblack/$base03/g" \
	-e "s/brightblue/$base0/g" \
	-e "s/brightcyan/$base1/g" \
	-e "s/brightgreen/$base01/g" \
	-e "s/brightmagenta/$violet/g" \
	-e "s/brightred/$orange/g" \
	-e "s/brightwhite/$base3/g" \
	-e "s/brightbrown/$base00/g" \
	-e "s/black/$base02/g" \
	-e "s/blue/$blue/g" \
	-e "s/brown/$yellow/g" \
	-e "s/cyan/$cyan/g" \
	-e "s/green/$green/g" \
	-e "s/magenta/$magenta/g" \
	-e "s/red/$red/g" \
	-e "s/white/$base2/g" \
	solarized-dark-ansi.ini > solarized-dark-truecolor.ini
