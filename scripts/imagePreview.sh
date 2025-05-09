#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq curl xdg-utils
image_name=$1
list_file="$PWD"
if [ -f "$PWD"/wallpapers/list.json ]; then
    list_file="$PWD/wallpapers/list.json"
else
    printf "[ERROR]%s\n" "Could not find database\n"
    exit 1
fi

if [ -z "$image_name" ]; then
    echo "Usage: preview-image.sh <image_name>"
    exit 1
fi

id=$(jq -r ".[] | select(.name == \"$image_name\") | .id" "$list_file")
ext=$(jq -r ".[] | select(.name == \"$image_name\") | .ext" "$list_file")

if [ -z "$id" ]; then
    printf "\033[0;31m[ERR] %s not found in %s \033[0m\n" "$image_name" "$list_file"
    exit 1
fi

downloadURL="https://i.imgur.com/$id.$ext"

# Create temporary file for the image
temp_file=$(mktemp /tmp/preview-image-XXXXXX.$ext)

# Cleanup function to remove temporary file on exit
cleanup() {
    rm -f "$temp_file"
}
trap cleanup EXIT

# Download the image
printf "\033[0;32m[INFO] Downloading %s to %s\033[0m\n" "$downloadURL" "$temp_file"
curl -s "$downloadURL" -o "$temp_file"

if [ $? -ne 0 ]; then
    printf "\033[0;31m[ERR] Failed to download image\033[0m\n"
    exit 1
fi

# Open the image with xdg-open
printf "\033[0;32m[INFO] Opening image with default viewer\033[0m\n"
xdg-open "$temp_file"
