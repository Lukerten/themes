#!/usr/bin/env bash

set -euo pipefail

# Script to update wallpaper list.json to use local paths instead of Imgur IDs
# Checks if images exist locally under ./wallpapers/images/
# Creates a new file list-new.json with updated entries

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIST_JSON="${SCRIPT_DIR}/list.json"
LIST_NEW_JSON="${SCRIPT_DIR}/list-new.json"
IMAGES_DIR="${SCRIPT_DIR}/images"

# Check if list.json exists
if [ ! -f "$LIST_JSON" ]; then
  echo "Error: list.json not found at $LIST_JSON"
  exit 1
fi

# Check if images directory exists
if [ ! -d "$IMAGES_DIR" ]; then
  echo "Error: Images directory not found at $IMAGES_DIR"
  echo "Create the directory or run download-wallpapers.sh first"
  exit 1
fi

# Create a temporary file for the new JSON content
temp_file=$(mktemp)

# Read the opening bracket
echo "[" >"$temp_file"

# Counter for entries
total=$(jq length "$LIST_JSON")
count=0

# Process each entry in the list.json file
jq -c '.[]' "$LIST_JSON" | while read -r entry; do
  count=$((count + 1))
  name=$(echo "$entry" | jq -r '.name')
  ext=$(echo "$entry" | jq -r '.ext')
  sha256=$(echo "$entry" | jq -r '.sha256')

  # Check if the image exists locally
  image_path="images/$name.$ext"
  full_image_path="${SCRIPT_DIR}/$image_path"

  if [ -f "$full_image_path" ]; then
    # Create entry with local path
    new_entry=$(jq -n \
      --arg name "$name" \
      --arg path "$image_path" \
      --arg ext "$ext" \
      --arg sha256 "$sha256" \
      '{name: $name, path: $path, ext: $ext, sha256: $sha256}')
  else
    # Keep original entry but with path field set to null
    new_entry=$(echo "$entry" | jq 'del(.id) | . + {path: null}')
    echo "Warning: Image '$name.$ext' not found locally"
  fi

  # Add comma separator for all but the last entry
  if [ "$count" -lt "$total" ]; then
    echo "$new_entry," >>"$temp_file"
  else
    echo "$new_entry" >>"$temp_file"
  fi

  # Progress update
  echo -ne "Processing: $count/$total\r"
done

# Close the JSON array
echo "]" >>"$temp_file"

# Format the JSON nicely
jq '.' "$temp_file" >"$LIST_NEW_JSON"
rm "$temp_file"

echo -e "\nDone! New list saved to $LIST_NEW_JSON"
echo "Please verify the new list and then rename it to list.json if it looks good."
