#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq curl

# Input file
list_file="$PWD"
if [ -f "$list_file/list.json" ]; then
    list_file="$list_file/list.json"
elif [ -f "$list_file"/pkgs/wallpapers/list.json ]; then
    list_file="$list_file/pkgs/wallpapers/list.json"
else
  printf "[ERROR]%s\n" "Could not find database\n"
  exit 1
fi

# Check for duplicate "name"
duplicate_names=$(jq -r '.[] | .name' "$list_file" | sort | uniq -d)
if [ -n "$duplicate_names" ]; then
    printf "[INFO]%s\n" "Duplicate names found"
    printf "[INFO]%s\n" "$duplicate_names"
else
    printf "[INFO]%s\n" "No duplicate names found."
fi

# Check for duplicate "sha256"
duplicate_sha256=$(jq -r '.[] | .sha256' "$list_file" | sort | uniq -d)
if [ -n "$duplicate_sha256" ]; then
    printf "[INFO]%s\n" "Duplicate sha256 values found"
    while IFS= read -r sha; do
        printf "[INFO]%s\n" "sha256: $sha"
        jq -r --arg sha "$sha" '.[] | select(.sha256 == $sha) | .name' "$list_file" | while IFS= read -r name; do
            printf "  - name: %s\n" "$name"
        done
    done <<< "$duplicate_sha256"
else
    printf "[INFO]%s\n" "No duplicate sha256 values found."
fi

jq 'sort_by(.name)' "$list_file" > temp.json && mv temp.json "$list_file"
jq 'map({name, id, ext, sha256})' "$list_file" > temp.json && mv temp.json "$list_file"

# List all Wallpaper names
wallpapers=$(jq -r '.[] | .name' "$list_file")
printf "[INFO]%s\n" "Available Wallpapers:"
for wallpaper in $wallpapers; do
  printf "  - %s\n" "$wallpaper"
done
