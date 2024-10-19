#!/bin/bash -e

auth="API_KEY"
url="https://api.e-z.host/files"

temp_file="/tmp/screenshot.png"
grim -g "$(slurp)" - > $temp_file

if [[ $(file --mime-type -b $temp_file) != "image/png" ]]; then
    rm $temp_file
    exit 1
fi

image_url=$(curl -X POST -F "file=@"$temp_file -H "key: "$auth -v "$url" 2>/dev/null)
echo $image_url > /tmp/upload.json
response_file="/tmp/upload.json"

success=$(cat /tmp/upload.json | jq -r ".success")
if [[ "$success" != "true" ]] || [[ "$success" == "null" ]]; then
    error=$(cat /tmp/upload.json | jq -r ".error")
    if [[ "$error" == "null" ]]; then
        notify-send "Error occurred while uploading. Please try again later." -a "Grim"
        rm $temp_file
        rm $response_file
        exit 1
    else
        notify-send "Error: $error" -a "Grim"
        rm $temp_file
        rm $response_file
        exit 1
    fi
fi

cat /tmp/upload.json | jq -r ".imageUrl" | xclip -sel c
notify-send "Image URL copied to clipboard" -a "Grim" -i $temp_file
rm $temp_file
