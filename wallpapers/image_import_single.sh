#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq curl

# Fetching Image
printf "[INFO]  %s %s\n" "Fetching image from:" "$1"
clientid="501d56d2805f6ec"
image="$(echo "$1" | rev | cut -d '/' -f1 | rev | cut -d '.' -f1)"
image=$(curl -s -H "Authorization: Client-ID $clientid" https://api.imgur.com/3/image/"$image" | jq -r '.data | "\(.description)|\(.type)|\(.id)"')

# Metadata
name="$2"
ext=$(echo "$image" | cut -d '|' -f 2 | cut -d '/' -f 2)
id=$(echo "$image" | cut -d '|' -f 3)
sha256=$(nix-prefetch-url https://i.imgur.com/"$id"."$ext")

# Check if ./list.json exists, else try ./pkgs/wallpapers/list.json
# If neither exists, create a new list.json
image_path="$PWD"
if [ -f "$image_path/list.json" ]; then
    image_path="$image_path/list.json"
elif [ -f "$image_path"/pkgs/wallpapers/list.json ]; then
    image_path="$image_path/pkgs/wallpapers/list.json"
else
    echo "[]" > "$image_path/list.json"
fi
printf "[INFO]  %s %s\n" "Using list.json in:" "$image_path"

# Ensure that "name" and "sha256" are unique
if jq -e --arg name "$name" '.[] | select(.name == $name)' "$image_path" > /dev/null; then
    printf "[ERROR] %s\n""An entry with the name '$name' already exists." >&2
    exit 1
fi

# Ensure that "sha256" is unique and print the existing entry's "name"
existing_name=$(jq -r --arg sha256 "$sha256" '.[] | select(.sha256 == $sha256) | .name' "$image_path")
if [ -n "$existing_name" ]; then
    printf "[ERROR] %s\n" "An entry with the sha256 '$sha256' already exists." >&2
    printf "[ERROR] %s\n" "The name of the existing entry is '$existing_name'." >&2
    exit 1
fi

# Create a new entry
new_entry=$(jq -n \
    --arg name "$name" \
    --arg ext "$ext" \
    --arg id "$id" \
    --arg sha256 "$sha256" \
    '{"name": $name, "ext": $ext, "id": $id, "sha256": $sha256}')

printf "Adding Entry %s to %s\n" "$name" "$image_path"
jq --argjson new_entry "$new_entry" '. += [$new_entry]' "$image_path" > temp.json && mv temp.json "$image_path"
jq 'sort_by(.name)' "$image_path" > temp.json && mv temp.json "$image_path"
jq 'map({name, id, ext, sha256})' "$image_path" > temp.json && mv temp.json "$image_path"
printf "Successfully added %s to %s\n" "$name" "$image_path"
