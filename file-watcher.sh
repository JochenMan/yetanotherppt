#!/bin/sh
# File watcher for automatic presentation regeneration

# Parameters passed from entrypoint.sh
INPUT_FILE="$1"
THEME="$2"
PRESENTATIONS_DIR="$3"
FOLDER_PATH="$4"

SOURCE_FILE="$PRESENTATIONS_DIR/$INPUT_FILE"

if [ ! -f "$SOURCE_FILE" ]; then
    echo "File watcher: Source file not found: $SOURCE_FILE"
    exit 1
fi

echo "File watcher: Monitoring $SOURCE_FILE for changes..."

# Watch for file modifications
inotifywait -m -e modify "$SOURCE_FILE" --format '%w%f %e' | while read file event; do
    echo "File watcher: Detected change in $file, regenerating presentation..."

    # Re-run pandoc to update the presentation
    pandoc -s -t revealjs \
        -o "$FOLDER_PATH/presentation.html" \
        "$SOURCE_FILE" \
        -V revealjs-url=./reveal.js \
        -V theme="$THEME" \
        --css custom-style.css

    if [ $? -eq 0 ]; then
        echo "File watcher: Presentation updated successfully!"
    else
        echo "File watcher: Error updating presentation"
    fi
done