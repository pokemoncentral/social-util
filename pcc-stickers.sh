#!/bin/bash

help="This script generates images that can be used as Telegram stickers: it
crops transparent border, scales and adds border to have a better visualization
over any background.
Needed arguments are input directory and output directory, it works on all files
inside the former and creates the latter if not already existing."
# read args
input_dir="$1"
output_dir="$2"
# set parameters
thickness=3
color="white"
# create output directory if it does not exist
mkdir -p "$output_dir"
# create a sticker for each image in input directory
for input_file in "$input_dir"/*; do
    if [[ -f "$input_file" ]]; then
        output_file="$output_dir/$(basename "$input_file")"
        convert \( \( \( "$input_file" -trim +repage \) -scale "506x506" \) -alpha Set -bordercolor none -border "${thickness}x${thickness}" \) \( -clone 0 -alpha off -fill "$color" -colorize 100 \) \( -clone 0 -alpha extract -morphology dilate disk:"$thickness" -blur 0x1 -level 50x100% \) \( -clone 1,2 -compose copy_opacity -composite \) -delete 1,2 +swap -compose over -composite "$output_file"
        echo "Converted \"$input_file\" to \"$output_file\""
    fi
done
