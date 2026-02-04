#!/bin/bash

# ==============================================================================
# SCRIPT: Bv1_scanner.sh (Part of 'vibe coding' suite)
# DESCRIPTION: Scans media directories for incorrectly named files (e.g., file_mkv)
#              and suggests corrections based on magic bytes and context.
# AUTHOR: Gemini & User
# ==============================================================================

# --- CONFIGURATION (Change these for your setup) ---
TARGET_DIR="/path/to/your/media/library" # The directory you want to scan
OUT="todo_Bv1_diagnose.csv"              # Analysis result file
DONE_LOG="processed.log"                 # Whitelist of already fixed files

# Ensure CSV header exists
if [ ! -f "$OUT" ]; then
    echo "Path;Claimed_Ext;Mime_Type;Context;Suggestion" > "$OUT"
fi

# 1. Load existing logs to enable Resume-Functionality (RAM-Optimization)
declare -A ALREADY_DONE
[ -f "$DONE_LOG" ] && while read -r l; do ALREADY_DONE["$l"]=1; done < "$DONE_LOG"
[ -f "$OUT" ] && while IFS=";" read -r p b i k v; do ALREADY_DONE["$p"]=1; done < "$OUT"

# 2. Count files for progress bar
echo "Calculating total files... (please wait)"
FILES_TO_SCAN=$(find "$TARGET_DIR" -type f -regextype posix-extended -regex ".*_[a-zA-Z0-9]{2,4}$" | wc -l)

if [ "$FILES_TO_SCAN" -eq 0 ]; then
    echo "No files with suffix pattern (e.g. _mkv) found. Check your TARGET_DIR."
    exit 0
fi

echo "Found $FILES_TO_SCAN files to analyze."

# 3. Scanner Loop
COUNT=0
find "$TARGET_DIR" -type f -regextype posix-extended -regex ".*_[a-zA-Z0-9]{2,4}$" | while read -r file; do
    ((COUNT++))
    
    # Progress Bar calculation
    PERCENT=$(( COUNT * 100 / FILES_TO_SCAN ))
    printf "\rProgress: [%d/%d] (%d%%) - Scan in progress..." "$COUNT" "$FILES_TO_SCAN" "$PERCENT"

    # Skip if already in DONE_LOG or CSV
    if [[ ${ALREADY_DONE["$file"]} ]]; then continue; fi

    # --- ANALYSIS ---
    # Extract extension-claim from filename (e.g. 'mkv' from 'movie_mkv')
    CLAIM=$(echo "$file" | rev | cut -d'_' -f1 | rev)
    MIME=$(file --brief --mime-type "$file")
    
    # Context detection (Change keywords to match your folder structure)
    case "$file" in
        *"Music"*|*"Audio"*)       CONTEXT="Audio" ;;
        *"Books"*|*"Ebooks"*)      CONTEXT="Ebook" ;;
        *"Movies"*|*"Series"*|*"Videos"*) CONTEXT="Video" ;;
        *)                         CONTEXT="General" ;;
    esac

    SUGGESTION="MANUAL_CHECK"
    
    # --- CASCADE LOGIC (The Core Intelligence) ---
    
    # 1. Playlists (XSPF)
    if [[ "$MIME" == *"xml"* || "$MIME" == *"text/plain"* ]] && [[ "$CLAIM" == "xspf" ]]; then
        SUGGESTION="FIX_XSPF"
    
    # 2. Video/Audio (M4A / MKV)
    elif [[ "$MIME" == *"audio/mp4"* || "$MIME" == *"video/mp4"* ]] && [[ "$CLAIM" == "m4a" ]]; then
        SUGGESTION="FIX_M4A"
    elif [[ "$MIME" == *"video/x-matroska"* ]]; then
        SUGGESTION="FIX_MKV"
    
    # 3. Images
    elif [[ "$MIME" == *"image/"* ]]; then
        SUGGESTION="FIX_IMAGE"
    
    # 4. Deep-Scan for Archives (The ZIP/EPUB chameleon)
    elif [[ "$MIME" == *"application/zip"* ]]; then
        # List zip content without extracting
        ZIP_CONTENT=$(unzip -l "$file" 2>/dev/null)
        
        if echo "$ZIP_CONTENT" | grep -iq "mimetype.*epub"; then
            SUGGESTION="FIX_EPUB"
        elif echo "$ZIP_CONTENT" | grep -iqE "\.mp3|\.flac|\.m4a"; then
            SUGGESTION="FIX_ZIP_ALBUM"
        else
            [[ "$CONTEXT" == "Ebook" ]] && SUGGESTION="FIX_EPUB_BY_CONTEXT" || SUGGESTION="FIX_ZIP"
        fi
    fi

    # Write results immediately (Crash-safe)
    echo "$file;$CLAIM;$MIME;$CONTEXT;$SUGGESTION" >> "$OUT"
done

# Output Statistics
echo -e "\n\nScan complete! Statistics for $OUT:"
cut -d';' -f5 "$OUT" | sort | uniq -c | sort -nr
