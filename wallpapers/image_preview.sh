#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq curl
image_name=$1
# use either ./list or ./pkgs/wallpapers/list.json
# else: throw an error
database="$PWD"
if [ -f "$database/list.json" ]; then
    database="$database/list.json"
elif [ -f "$database/pkgs/wallpapers/list.json" ]; then
    database="$database/pkgs/wallpapers/list.json"
else
    echo "No list.json found in $database or $database/pkgs/wallpapers"
    exit 1
fi

if [ -z "$image_name" ]; then
    echo "Usage: preview-image.sh <image_name>"
    exit 1
fi

id=$(jq -r ".[] | select(.name == \"$image_name\") | .id" "$database")
ext=$(jq -r ".[] | select(.name == \"$image_name\") | .ext" "$database")

if [ -z "$id" ]; then
    printf "\033[0;31m[ERR] %s not found in %s \033[0m\n" "$image_name" "$database"
    exit 1
fi

echo "https://i.imgur.com/$id.$ext"
