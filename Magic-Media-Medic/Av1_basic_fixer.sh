#!/bin/bash
# Phase 1: Der einfache Umbenenner ohne Schnickschnack
TARGET_DIR="."
find "$TARGET_DIR" -type f | while read -r file; do
    ext=$(file --brief --extension "$file" | cut -d'/' -f1)
    if [[ "$ext" != "???" ]]; then
        base_name=$(echo "$file" | sed -r 's/_[a-zA-Z0-9]{2,4}$//')
        mv -n "$file" "${base_name}.${ext}"
    fi
done
