#!/bin/sh
set -e

# Pure Docker entrypoint for yetanotherppt
# Handles conversion and serving in one container

PRESENTATIONS_DIR="/usr/share/nginx/html/presentations"
WEB_ROOT="/usr/share/nginx/html"

# Default values
INPUT_FILE=""
THEME="white"
PORT="80"
PRESENTATION_FOLDER=""

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
        --folder)
            PRESENTATION_FOLDER="$2"
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

# Validate input file exists
if [ ! -f "$PRESENTATIONS_DIR/$INPUT_FILE" ]; then
    echo "File not found: $INPUT_FILE"
    exit 1
fi

# Create timestamped folder and copy assets
FOLDER_PATH="$WEB_ROOT/$PRESENTATION_FOLDER"
mkdir -p "$FOLDER_PATH"

# Copy reveal.js, CSS, and background to the timestamped folder
cp -r "$WEB_ROOT/reveal.js" "$FOLDER_PATH/"
cp "$WEB_ROOT/custom-style.css" "$FOLDER_PATH/"
cp "$WEB_ROOT/background.jpg" "$FOLDER_PATH/"

echo "Converting $INPUT_FILE with theme $THEME in folder $PRESENTATION_FOLDER..."

echo "Running command:"
echo pandoc -s -t revealjs \
    -o "$FOLDER_PATH/presentation.html" \
    "$PRESENTATIONS_DIR/$INPUT_FILE" \
    -V revealjs-url=./reveal.js \
    -V theme="$THEME" \
    --css custom-style.css

# Convert presentation
pandoc -s -t revealjs \
    -o "$FOLDER_PATH/presentation.html" \
    "$PRESENTATIONS_DIR/$INPUT_FILE" \
    -V revealjs-url=./reveal.js \
    -V theme="$THEME" \
    --css custom-style.css

# No copying needed! User assets are directly accessible at /presentations/

echo "Presentation converted successfully!"

# Start nginx in the background
echo "Starting web server..."
nginx -g "daemon off;" &
NGINX_PID=$!

# Start file watcher for auto-regeneration
echo "Starting file watcher for auto-regeneration..."
nohup /file-watcher.sh "$INPUT_FILE" "$THEME" "$PRESENTATIONS_DIR" "$FOLDER_PATH" > /dev/null 2>&1 &

# Start the background PDF generation, which will wait for the server
echo "Starting background PDF generation..."
nohup /generate-pdf-in-background.sh &

# Store the folder name for PDF generation
echo "$PRESENTATION_FOLDER" > "$WEB_ROOT/current-presentation-folder"

echo "Presentation ready at: http://localhost:$PORT/$PRESENTATION_FOLDER/presentation.html"
echo "PDF will be available shortly at: http://localhost:$PORT/$PRESENTATION_FOLDER/presentation.pdf"
echo "File watcher active - presentation will auto-regenerate when $INPUT_FILE changes!"

# Wait for nginx to exit. This keeps the container alive.
wait $NGINX_PID
