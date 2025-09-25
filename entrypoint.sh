#!/bin/sh
set -e

# Pure Docker entrypoint for yetanotherppt
# Handles conversion and serving in one container

PRESENTATIONS_DIR="/usr/share/nginx/html/presentations"
WEB_ROOT="/usr/share/nginx/html"

# Default values
INPUT_FILE=""
THEME="black"
PORT="80"
OUTPUT_DIR_NAME=""

# Parse arguments
while [ $# -gt 0 ]; do
    case $1 in
        --file)
            INPUT_FILE="$2"
            shift 2
            ;;
        --theme)
            THEME="$2"
            shift 2
            ;;
        --port)
            PORT="$2"
            shift 2
            ;;
        --output-dir-name)
            OUTPUT_DIR_NAME="$2"
            shift 2
            ;;
        *)
           # Positional argument - treat as filename
           if [ -z "$INPUT_FILE" ]; then
               INPUT_FILE="$1"
           fi
           shift
           ;;
    esac
done

# Require input file to be specified
if [ -z "$INPUT_FILE" ]; then
    echo "Error: No input file specified"
    echo "Usage: --file myfile.md"
    exit 1
fi

INPUT_FILE_PATH="$PRESENTATIONS_DIR/$INPUT_FILE"

# Validate input file exists
if [ ! -f "$INPUT_FILE_PATH" ]; then
    echo "File not found: $INPUT_FILE_PATH"
    exit 1
fi

# Create timestamped output-dir-name and symlink assets with precedence
OUTPUT_DIR_PATH="$WEB_ROOT/$OUTPUT_DIR_NAME"
INPUT_DIR=$(dirname "$INPUT_FILE_PATH")

mkdir -p "$OUTPUT_DIR_PATH"

# 1. Prioritize the core reveal.js framework
ln -s "$WEB_ROOT/reveal.js" "$OUTPUT_DIR_PATH/reveal.js"

# 2. Link all user assets from the source directory.
# The -n flag prevents overwriting the reveal.js link we just made.
# This allows user-supplied css and background to be linked.
for item in "$INPUT_DIR"/*; do
    # Check if item exists to handle empty directories
    if [ -e "$item" ]; then
        ln -s -n "$item" "$OUTPUT_DIR_PATH/"
    fi
done

# 3. Link default assets as fallbacks if not provided by the user.
if [ ! -e "$OUTPUT_DIR_PATH/custom-style.css" ]; then
    ln -s "$WEB_ROOT/custom-style.css" "$OUTPUT_DIR_PATH/custom-style.css"
fi
if [ ! -e "$OUTPUT_DIR_PATH/background.jpg" ]; then
    ln -s "$WEB_ROOT/background.jpg" "$OUTPUT_DIR_PATH/background.jpg"
fi

echo "Converting $INPUT_FILE with theme $THEME in output-dir-name $OUTPUT_DIR_NAME..."

echo "Running command:"
echo pandoc -s -t revealjs \
    -o "$OUTPUT_DIR_PATH/presentation.html" \
    "$INPUT_FILE_PATH" \
    -V revealjs-url=./reveal.js \
    -V theme="$THEME" \
    --css custom-style.css \
    --include-in-header /usr/share/nginx/html/header.html

# Convert presentation
pandoc -s -t revealjs \
    -o "$OUTPUT_DIR_PATH/presentation.html" \
    "$INPUT_FILE_PATH" \
    -V revealjs-url=./reveal.js \
    -V theme="$THEME" \
    --css custom-style.css \
    --include-in-header /usr/share/nginx/html/header.html

# No copying needed! User assets are directly accessible at /presentations/

echo "Presentation converted successfully!"

# Start nginx in the background
echo "Starting web server..."
nginx -g "daemon off;" &
NGINX_PID=$!

# Start file watcher for auto-regeneration
echo "Starting file watcher for auto-regeneration..."
nohup /file-watcher.sh "$INPUT_FILE_PATH" "$THEME" "$OUTPUT_DIR_PATH" > /dev/null 2>&1 &

# Start the background PDF generation, which will wait for the server
echo "Starting background PDF generation..."
nohup /generate-pdf-in-background.sh &

# Store the output-dir-name name for PDF generation
echo "$OUTPUT_DIR_NAME" > "$WEB_ROOT/current-presentation-dir"

# Wait for nginx to exit. This keeps the container alive.
wait $NGINX_PID
