#!/bin/bash
#####   HELP    #############################################################
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

show_help() {
  echo "Usage: ./$(basename $0) [OPTIONS]"
  echo "Options:"
  echo "  -h  Display this help message"
  echo "  -u  Provide url to page that you want to follow [REQUIRED]"
  echo "  -i  Interval at which the page will be checked in seconds, deafult 3600"
  exit 0
}

INTERVAL_TIME=3600
while getopts 'u:i:h' OPT
do
    case "$OPT" in
        u)    URL="$OPTARG" ;;
        h)    show_help;;
        i)    INTERVAL_TIME="$OPTARG" ;;
        *)    echo -e "${RED}ERROR: the options are -u {arg}, -i {arg}, -h${NC}"; exit 1 ;;
    esac
done
# VALIDATE ARGUMENTS
if ! [[ $URL ]]; then
  echo -e "${RED}Error: no url provided!${NC}"
  exit 1
fi

#####   PROGRAM   ###########################################################
#URL="https://lawiny.topr.pl/viewpdf"
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
        sleep $INTERVAL_TIME
    else
        { # try
            curl -o "$ARCHIVE$(date +%F)_avalanche.pdf" $URL && old_md5="$new_md5" && python3 -u "./main.py" && (
            echo "new $(date +%F)_avalanche.pdf update from '$URL';"
            echo "$(date +%F) --- $(date +%T) <SUCCESS> from '$URL';"  >> "$LOGS/logs.log"
            )
        } || { # catch
            echo "new $(date +%F)_avalanche.pdf FAIL"
            echo "$(date +%F) --- $(date +%T) <FAIL> from '$URL' $ERR ;" >> "$LOGS/logs.log"
            sleep $INTERVAL_TIME
        }
    fi
done



