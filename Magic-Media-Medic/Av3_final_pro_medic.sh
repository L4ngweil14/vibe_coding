#!/bin/bash
# Phase 3: Die finale Version - Schnell, sicher, mit Gedächtnis
TARGET_DIR="."
DATA_DIR=".script_data"
DONE_FILE="$DATA_DIR/processed.log"
mkdir -p "$DATA_DIR"
touch "$DONE_FILE"

declare -A finished
while IFS= read -r line; do finished["$line"]=1; done < "$DONE_FILE"

find "$TARGET_DIR" -type f | while read -r file; do
    if [[ ${finished["$file"]} ]] || [[ ! "$file" =~ _[a-zA-Z0-9]{2,4}$ ]]; then
        continue
    fi

    ext=$(file --brief --extension "$file" | cut -d'/' -f1)
    # Spezial-Bending für FLAC/MP3 mit ID3-Tags
    if [[ "$ext" == "???" ]]; then
        type=$(file --brief "$file")
        if [[ "$type" == *"FLAC"* ]]; then ext="flac";
        elif [[ "$type" == *"Audio file"* ]]; then ext="mp3";
        else continue; fi
    fi

    base_name=$(echo "$file" | sed -r 's/_[a-zA-Z0-9]{2,4}$//')
    mv -n "$file" "${base_name}.${ext}"
    echo "$file" >> "$DONE_FILE"
done
