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
        *)
            # Positional argument - treat as filename
            if [ -z "$INPUT_FILE" ]; then
                INPUT_FILE="$1"
            fi
            shift
            ;;
    esac
done

# Auto-detect input file if not specified
if [ -z "$INPUT_FILE" ]; then
    if [ -f "$PRESENTATIONS_DIR/presentation.md" ]; then
        INPUT_FILE="presentation.md"
    elif [ -f "$PRESENTATIONS_DIR/presentation.rst" ]; then
        INPUT_FILE="presentation.rst"
    elif [ -f "$PRESENTATIONS_DIR/slides.md" ]; then
        INPUT_FILE="slides.md"
    elif [ -f "$PRESENTATIONS_DIR/slides.rst" ]; then
        INPUT_FILE="slides.rst"
    else
        echo "No presentation file found in mounted directory"
        echo "Expected: presentation.md, presentation.rst, slides.md, or slides.rst"
        echo "Or specify: --file myfile.md"
        exit 1
    fi
fi

# Validate input file exists
if [ ! -f "$PRESENTATIONS_DIR/$INPUT_FILE" ]; then
    echo "File not found: $INPUT_FILE"
    exit 1
fi

echo "Converting $INPUT_FILE with theme $THEME..."

echo "Running command:"
echo pandoc -s -t revealjs \
    -o "$WEB_ROOT/presentation.html" \
    "$PRESENTATIONS_DIR/$INPUT_FILE" \
    -V revealjs-url=./reveal.js \
    -V theme="$THEME" \
    --css custom-style.css

# Convert presentation
pandoc -s -t revealjs \
    -o "$WEB_ROOT/presentation.html" \
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

# Start the background PDF generation, which will wait for the server
echo "Starting background PDF generation..."
nohup /generate-pdf-in-background.sh &

echo "Presentation ready at: http://localhost:$PORT/presentation.html"
echo "PDF will be available shortly at: http://localhost:$PORT/presentation.pdf"

# Wait for nginx to exit. This keeps the container alive.
wait $NGINX_PID
