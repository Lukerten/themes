#!/usr/bin/env bash
set -euo pipefail

# Create images directory if it doesn't exist
mkdir -p wallpapers/images

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse the JSON file and extract name, id and ext for each wallpaper
jq -r '.[] | "\(.name)|\(.id)|\(.ext)"' "$SCRIPT_DIR/list.json" | while IFS="|" read -r name id ext; do
  echo "Downloading $name.$ext from https://i.imgur.com/$id.$ext"

  # Download the image
  if curl -s --fail "https://i.imgur.com/$id.$ext" -o "$SCRIPT_DIR/images/$name.$ext"; then
    echo "Successfully downloaded $name.$ext"
  else
    echo "Failed to download $name.$ext"
  fi

  # Add a small delay to avoid overwhelming the API
  sleep 0.5
done

echo "All wallpapers downloaded to wallpapers/images/"
