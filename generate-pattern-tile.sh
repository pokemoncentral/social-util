#!/bin/bash

help="This script generates an image that can be used as a pattern. Arguments:
-l: logo that needs to be used from 'logos' directory, e.g. 'yellow' to use logo-yellow.png.
-b: background color (optional, defaults to white).
-t: opacity of logo (optional, should be decimal part, e.g. '50' to use 50% opacity).
Result is saved to 'patterns' directory, which contains some examples.
It is possible to override default input and/or output file using -i and/or -o respectively."
# get script directory
script_dir="$(dirname "$(realpath $0)")"
# parse args
while getopts "hl:i:b:t:o:" arg; do
    case $arg in
    h)
        echo "$help"
        exit 0
        ;;
    l)
        logo="$OPTARG"
        ;;
    i)
        input="$OPTARG"
        ;;
    b)
        background="$OPTARG"
        ;;
    t)
        opacity="$OPTARG"
        ;;
    o)
        output="$OPTARG"
        ;;
    *)
        exit 1
        ;;
    esac
done
# set default values
background="${background:-white}"
opacity="${opacity:-100}"
if [[ -z $input ]]; then
    input="$script_dir/logos/logo-$logo.png"
fi
if [[ -z $output ]]; then
    output="$script_dir/patterns/pattern-$logo-$background-$opacity.png"
fi
# scale logo, then make tile
if [[ $opacity == 100 ]]; then
    magick "$input" -scale '160x160!' "$output"
else
    magick "$input" -scale '160x160!' -alpha Set -channel A +level 0,${opacity}% +channel "$output"
fi
magick -size '320x320' xc:"$background" \
    "$output" -gravity 'center' -geometry '+0+0' -composite \
    "$output" -gravity 'northwest' -geometry '-80-80' -composite \
    "$output" -gravity 'northeast' -geometry '-80-80' -composite \
    "$output" -gravity 'southwest' -geometry '-80-80' -composite \
    "$output" -gravity 'southeast' -geometry '-80-80' -composite \
    "$output"
# print final message
echo "Pattern generated from '$input' with $background background color and saved as '$output'"
