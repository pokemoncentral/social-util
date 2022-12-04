#!/bin/bash

help="This script generates images for Pokémon Central socials: is uses a
pattern as background and adds text if provided. Arguments:
-i: path of input file.
-c: category (determines text), can be 'uo' for '#UscivaOggi', 'pb' for
'#PokeBirthday', 'spo' for '#SeriePokemonOggi'.
-t: can be used to add a different text.
-f: to specify a different font (by default uses RooneySansWeb which is not free
to use).
-o: path of output file."
# get script directory and path of background file
script_dir="$(dirname "$(realpath $0)")"
tile_file="$script_dir/patterns/pattern-yellow-white-50.png"
# parse args
while getopts "hi:c:t:o:" arg; do
    case $arg in
    h)
        echo "$help"
        exit 0
        ;;
    i)
        input="$OPTARG"
        ;;
    c)
        case $OPTARG in
        uo)
            text="#UscivaOggi"
            ;;
        pb)
            text="#PokeBirthday"
            ;;
        spo)
            text="#SeriePokemonOggi"
            ;;
        *)
            exit 1
            ;;
        esac
        ;;
    t)
        text="$OPTARG"
        ;;
    f)
        font="$OPTARG"
        ;;
    o)
        output="$OPTARG"
        ;;
    *)
        exit 1
        ;;
    esac
done
# set default font if value is empty
if [[ -z "$font" ]]; then
    font="rooneysansweb-bold"
fi
# set output file extension as PNG (needed because JPEG doesn't support transparency)
output="${output/'.jpg'/'.png'}"
output="${output/'.jpeg'/'.png'}"
# resize to 1080p if larger (some socials have a limit on image size, this reduces it)
input_width=$(identify -format '%w' "$input")
input_height=$(identify -format '%h' "$input")
if [[ $input_width -gt 1080 || $input_height -gt 1080 ]]; then
    magick "$input" -scale "1080x1080>" "$output"
    input_width=$(identify -format '%w' "$output")
    input_height=$(identify -format '%h' "$output")
else
    cp "$input" "$output"
fi
# if image is too much stretched, add some transparent border (Instagram has
# annoying aspect ratio limitations)
if [[ $((10 * $input_width / $input_height)) -gt 20 ]]; then
    input_height=$(($input_width / 2))
    magick -size "${input_width}x${input_height}" xc:none \( "$output" \) -gravity 'center' -geometry '+0+0' -composite "$output"
elif [[ $input_height -gt $input_width ]]; then
    input_width=$input_height
    magick -size "${input_width}x${input_height}" xc:none \( "$output" \) -gravity 'center' -geometry '+0+0' -composite "$output"
fi
# compute final width and height, more upper border is added if text is needed
if [[ $input_width -gt $input_height ]]; then
    border=$(($input_width / 10))
else
    border=$(($input_height / 10))
fi
output_width=$(($input_width + 2 * $border))
if [[ -z "$text" ]]; then
    output_height=$(($input_height + 2 * $border))
else
    output_height=$(($input_height + 4 * $border))
fi
# add shadow, background and (if provided) text
shadowsize=$(($border / 14))
shadow="100x$shadowsize+$shadowsize+$shadowsize"
shadowcolor="black"
img_with_bg="-size '${output_width}x${output_height}' tile:'$tile_file' \( \"$output\" \( +clone -background '$shadowcolor' -shadow '$shadow' \) +swap -background none -layers merge +repage \) -gravity 'south' -geometry '+0+$border' -composite"
if [[ -z "$text" ]]; then
    # add background only
    command="magick $img_with_bg \"$output\""
    #echo "$command"
    eval $command
    # print final message
    echo "Image generated from \"$input\" and saved as \"$output\""
else
    # add background and text
    command="magick \( $img_with_bg \) \( -size '${input_width}x$((2 * $border))' -font '$font' -fill '#f6bd1f' -background 'none' label:'$text' -trim -gravity 'center' -extent '${input_width}x$((2 * $border))' \( +clone -background '$shadowcolor' -shadow '$shadow' \) +swap -background none -layers merge +repage \) -gravity 'north' -geometry '+0+$(($border / 2))' -composite \"$output\""
    #echo "$command"
    eval $command
    # print final message
    echo "Image generated from \"$input\" with text '$text' and saved as \"$output\""
fi
