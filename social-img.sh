#!/bin/bash

help="This script generates images for Pokémon Central socials: is uses a
pattern as background and adds text if provided. Arguments:
-i: path of input file.
-l: before being put on background, input image is resized to have both width
and height not greater than this value (some socials have limits on image size
and this scaling helps reduce it); default is 1080, 0 can be passed to avoid
this resizing and use the image as is.
-b: to specify border size (can be useful when using image with some transparent
background, be careful using it with text).
-t: used to set the text; if both this and -c are not provided no text will be
added to final image.
-c: shortcuts for frequently used texts:
    + 'uo' for '#UscivaOggi'
    + 'pb' for '#PokeBirthday'
    + 'spo' for '#SeriePokemonOggi'
-f: to specify a different font (by default uses RooneySansWeb which is not free
to use).
-p: pattern to use (by default patterns/pattern-yellow-white-50.png).
-o: path of output file."
# get script directory and path of background file
script_dir="$(dirname "$(realpath $0)")"
tile_file="$script_dir/patterns/pattern-yellow-white-50.png"
# set default values for some args
font="rooneysansweb-bold"
limit=1080
# parse args
while getopts "hi:l:b:t:c:f:p:o:" arg; do
    case $arg in
    h)
        echo "$help"
        exit 0
        ;;
    i)
        input="$OPTARG"
        ;;
    l)
        limit="$OPTARG"
        ;;
    b)
        border="$OPTARG"
        ;;
    t)
        text="$OPTARG"
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
    f)
        font="$OPTARG"
        ;;
    p)
        tile_file="$OPTARG"
        ;;
    o)
        output="$OPTARG"
        ;;
    *)
        exit 1
        ;;
    esac
done
# set output file extension as PNG (needed because JPEG doesn't support transparency)
output="${output/'.jpg'/'.png'}"
output="${output/'.jpeg'/'.png'}"
# get width and height of input image
input_width=$(identify -format '%w' "$input")
input_height=$(identify -format '%h' "$input")
# resize if greater than limit
if [[ $limit -gt 0 ]]; then
    if [[ $input_width -gt $limit || $input_height -gt $limit ]]; then
        magick "$input" -scale "${limit}x${limit}>" "$output"
        input_width=$(identify -format '%w' "$output")
        input_height=$(identify -format '%h' "$output")
    else
        cp "$input" "$output"
    fi
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
if [[ -z "$border" ]]; then
    if [[ $input_width -gt $input_height ]]; then
        border=$(($input_width / 10))
    else
        border=$(($input_height / 10))
    fi
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
    # set final message
    message="Image generated from \"$input\" and saved as \"$output\""
else
    # add background and text
    command="magick \( $img_with_bg \) \( -size '${input_width}x$((2 * $border))' -font '$font' -fill '#f6bd1f' -background 'none' label:'$text' -trim -gravity 'center' -extent '${input_width}x$((2 * $border))' \( +clone -background '$shadowcolor' -shadow '$shadow' \) +swap -background none -layers merge +repage \) -gravity 'north' -geometry '+0+$(($border / 2))' -composite \"$output\""
    # set final message
    message="Image generated from \"$input\" with text '$text' and saved as \"$output\""
fi
#echo "$command"
eval $command
echo "$message"
