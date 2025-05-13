#!/bin/bash

# Script to update wallpaper library by generating list.json with all images from ./images folder

# Output file path
output_file="./wallpapers/list.json"

# Ensure the directory exists
mkdir -p ./wallpapers

echo "[" >$output_file

# Find all image files, sort them, and process each one
find ./images -type f | sort | while read file; do
    # Get just the filename
    filename=$(basename "$file")
    # Get extension without the dot
    ext="${filename##*.}"
    # Get name without extension
    name="${filename%.*}"

    # Add entry to JSON file
    echo "  {" >>$output_file
    echo "    \"name\": \"$name\"," >>$output_file
    echo "    \"path\": \"images/$filename\"," >>$output_file
    echo "    \"ext\": \"$ext\"" >>$output_file

    # Check if this is the last file to avoid trailing comma
    if [ "$(find ./images -type f | sort | tail -n1)" = "$file" ]; then
        echo "  }" >>$output_file
    else
        echo "  }," >>$output_file
    fi
done

echo "]" >>$output_file

echo "Wallpaper list updated at $output_file"
