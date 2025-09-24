#!/bin/bash

help="This script generates an image from a pattern contained in patterns/ directory,
saving it in backgrounds/ directory. Arguments:
-p: pattern to use (only part between 'pattern-' and '.png').
-s: size of output image (default 1080x1920)."
# get script directory
script_dir="$(dirname "$(realpath $0)")"
# parse args
while getopts "hp:s:" arg; do
    case $arg in
    h)
        echo "$help"
        exit 0
        ;;
    p)
        pattern="$OPTARG"
        ;;
    s)
        output_size="$OPTARG"
        ;;
    *)
        exit 1
        ;;
    esac
done
# set default values
output_size="${output_size:-1080x1920}"
pattern="${pattern:-yellow-white-50}"
# set paths of pattern file and output file
pattern_file="$script_dir/patterns/pattern-$pattern.png"
output_file="$script_dir/backgrounds/background-$pattern-$output_size.png"
# generate image
convert -size "$output_size" tile:"$pattern_file" "$output_file"
# print final message
echo "Background image generated from '$pattern_file' and saved as '$output_file'"
