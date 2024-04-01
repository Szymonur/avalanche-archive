#!/bin/bash

URL="https://lawiny.topr.pl/viewpdf"
URL_TO_FOLLOW="file:///Users/szymon/PycharmProjects/python_learning_projects/avalanges/tmp/index.html"
TEMP_DIR="./tmp/page_content"
TEMP_FILE="$TEMP_DIR/page_content.html"
ARCHIVE="./archive/"
LOGS="./logs"

mkdir -p "$TEMP_DIR"
mkdir -p "$ARCHIVE"
mkdir -p "$LOGS"
touch "$LOGS/logs.log"

curl -s "$URL_TO_FOLLOW" > "$TEMP_FILE"
old_md5=$(md5 -q "$TEMP_FILE")

while true; do
    curl -s "$URL_TO_FOLLOW" > "$TEMP_FILE"
    new_md5=$(md5 -q "$TEMP_FILE")
    if [ "$old_md5" == "$new_md5" ]; then
        sleep 5
    else
        { # try
            curl -o "$ARCHIVE$(date +%F)_avalanche.pdf" $URL && old_md5="$new_md5" && python3 -u "./main.py" && (
            echo "new $(date +%F)_avalanche.pdf update from '$URL';"
            echo "$(date +%F) --- $(date +%T) <SUCCESS> from '$URL';"  >> "$LOGS/logs.log"
            )
        } || { # catch
            echo "new $(date +%F)_avalanche.pdf FAIL"
            echo "$(date +%F) --- $(date +%T) <FAIL> from '$URL';" >> "$LOGS/logs.log"
            sleep 3600
        }
    fi
done

