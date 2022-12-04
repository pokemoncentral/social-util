#!/bin/bash

help="This script work as social-img.sh with same arguments, except for -i and -o
which should be directories instead of files: all items inside input directory are
processed in batch and saved in output directory."
# get script directory
script_dir="$(dirname "$(realpath $0)")"
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
        cat="$OPTARG"
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
# create output directory if it does not exist
mkdir -p "$output"
# invoke social-img.sh for each file
for item in "$2"/*; do
    if [[ -f "$item" ]]; then
        command="bash \"$script_dir\"/social-img.sh -i \"$item\""
        if [[ ! -z "$cat" ]]; then
            command+=" -c \"$cat\""
        elif [[ ! -z "$text" ]]; then
            command+=" -t \"$text\""
        fi
        if [[ ! -z "$font" ]]; then
            command+=" -f \"$font\""
        fi
        command+=" -o \"$output/$(basename "$item")\""
        #echo "$command"
        eval $command
    fi
done
