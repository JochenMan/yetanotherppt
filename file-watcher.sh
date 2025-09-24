#!/bin/sh
# File watcher for automatic presentation regeneration

# Parameters passed from entrypoint.sh
INPUT_FILE="$1"
THEME="$2"
PRESENTATIONS_DIR="$3"
OUTPUT_DIR_PATH="$4"

SOURCE_FILE="$PRESENTATIONS_DIR/$INPUT_FILE"

if [ ! -f "$SOURCE_FILE" ]; then
    echo "File watcher: Source file not found: $SOURCE_FILE"
    exit 1
fi

DIR="$(dirname "$SOURCE_FILE")"
BASE="$(basename "$SOURCE_FILE")"

echo "File watcher: Monitoring $SOURCE_FILE for changes..."

# Watch the directory and react only when our file changes.
# Covers in-place writes, atomic saves, metadata-only changes, and new files moved into place.
inotifywait -m -e CLOSE_WRITE,MODIFY,ATTRIB,MOVED_TO,CREATE \
    --format '%w %e %f' "$DIR" | while read -r watch_dir event file; do
    [ "$file" = "$BASE" ] || continue
    echo "File watcher: Detected $event on $watch_dir$file, regenerating presentation..."

    # Re-run pandoc to update the presentation
    pandoc -s -t revealjs \
        -o "$OUTPUT_DIR_PATH/presentation.html" \
        "$SOURCE_FILE" \
        -V revealjs-url=./reveal.js \
        -V theme="$THEME" \
        --css custom-style.css

    if [ $? -eq 0 ]; then
        echo "File watcher: Presentation updated successfully!"

        # Regenerate PDF as well
        echo "File watcher: Regenerating PDF..."

        # Get the presentation folder name
        PRESENTATION_DIR_NAME=$(cat /usr/share/nginx/html/current-presentation-dir 2>/dev/null || echo "")

        cd /app && node pdf-generator.js \
            "http://localhost/$PRESENTATION_DIR_NAME/presentation.html" \
            "$OUTPUT_DIR_PATH/presentation.pdf" \
            > /dev/null 2>&1

        if [ $? -eq 0 ]; then
            echo "File watcher: PDF updated successfully!"
        else
            echo "File watcher: Error updating PDF"
        fi
    else
        echo "File watcher: Error updating presentation"
    fi
done
