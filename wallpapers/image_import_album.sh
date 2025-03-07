if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <album_id>"
    exit 1
fi

album="$1"
clientid="0c2b2b57cdbe5d8"

function fetch_image() {
    jq -n \
        --arg name "$(echo "$1"" | cut -d '|' -f 1)" \
        --arg ext "$(echo "$1"" | cut -d '|' -f 2 | cut -d '/' -f 2)" \
        --arg id "$(echo "$1"" | cut -d '|' -f 3)" \
        --arg sha256 "$(nix-prefetch-url https://i.imgur.com/$id.$ext)" \
        '{"name": $name, "ext": $ext, "id": $id, "sha256": $sha256}'
}

result=$(https api.imgur.com/3/album/"$album" Authorization:"Client-ID $clientid")
images=$(echo "$result" | jq -r '.data.images[] | "\(.description)|\(.type)|\(.id)"')

# Ensure list.json exists
image_path="$PWD"
if [ -f "$image_path/list.json" ]; then
    image_path="$image_path/list.json"
elif [ -f "$image_path"/pkgs/wallpapers/list.json ]; then
    image_path="$image_path/pkgs/wallpapers/list.json"
else
    echo "[]" > "$image_path/list.json"
fi
printf "[INFO]  %s %s\n" "Using list.json in:" "$image_path"

echo "["
while read -r image; do
    new_entry=$(fetch_image "$image")

    name=$(echo "$new_entry" | jq -r '.name')
    sha256=$(echo "$new_entry" | jq -r '.sha256')

    # Ensure that "name" and "sha256" are unique
    if jq -e --arg name "$name" '.[] | select(.name == $name)' "$image_path" > /dev/null; then
        printf "[ERROR] %s\n" "An entry with the name '$name' already exists." >&2
        continue
    fi

    existing_name=$(jq -r --arg sha256 "$sha256" '.[] | select(.sha256 == $sha256) | .name' "$image_path")
    if [ -n "$existing_name" ]; then
        printf "[ERROR] %s\n" "An entry with the sha256 '$sha256' already exists." >&2
        printf "[ERROR] %s\n" "The name of the existing entry is '$existing_name'." >&2
        continue
    fi

    # Add new entry
    jq --argjson new_entry "$new_entry" '. += [$new_entry]' "$image_path" > temp.json && mv temp.json "$image_path"
    jq 'sort_by(.name)' "$image_path" > temp.json && mv temp.json "$image_path"
    jq 'map({name, id, ext, sha256})' "$image_path" > temp.json && mv temp.json "$image_path"
    printf "Successfully added %s to %s\n" "$name" "$image_path"
done <<< "$images"
wait
echo "]"
