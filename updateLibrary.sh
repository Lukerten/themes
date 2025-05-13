#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq curl

# Script to update wallpaper library by generating list.json with all images from ./images folder

# Output file path
output_file="./wallpapers/list.json"

# Ensure the directory exists
mkdir -p ./wallpapers

# Create a temporary array to hold all image entries
temp_array=()

# Find all image files, sort them, and process each one
while read -r file; do
    # Get just the filename
    filename=$(basename "$file")
    # Get extension without the dot
    ext="${filename##*.}"
    # Get name without extension
    name="${filename%.*}"

    # Create JSON object for this file
    entry=$(jq -n \
        --arg name "$name" \
        --arg path "images/$filename" \
        --arg ext "$ext" \
        '{name: $name, path: $path, ext: $ext}')

    # Add to our array
    temp_array+=("$entry")

done < <(find ./images -type f | sort)

# Join all entries and write to the output file
printf '%s\n' "${temp_array[@]}" | jq -s '.' >"$output_file"

printf "Wallpaper list updated at %s\n" "$output_file"
