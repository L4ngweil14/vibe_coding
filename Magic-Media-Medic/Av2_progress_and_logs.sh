#!/bin/bash
# Phase 2: Fokus auf Feedback und Fehler-Tracking
TARGET_DIR="."
LOG_FILE="problem_files.log"
total=$(find "$TARGET_DIR" -type f | wc -l)
count=0

find "$TARGET_DIR" -type f | while read -r file; do
    ((count++))
    percent=$(( count * 100 / total ))
    printf "\r[%d%%] Check: %-50.50s" "$percent" "${file##*/}"
    
    ext=$(file --brief --extension "$file" | cut -d'/' -f1)
    if [[ "$ext" == "???" ]]; then
        echo "Unbekannt: $file" >> "$LOG_FILE"
        continue
    fi
    base_name=$(echo "$file" | sed -r 's/_[a-zA-Z0-9]{2,4}$//')
    mv -n "$file" "${base_name}.${ext}"
done
