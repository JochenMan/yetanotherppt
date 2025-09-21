#!/bin/sh
# Waits for the web server to be ready, then generates the PDF.
LOG_FILE="/usr/share/nginx/html/pdf-generation.log"

# Get the current presentation folder
PRESENTATION_FOLDER=$(cat /usr/share/nginx/html/current-presentation-folder 2>/dev/null || echo "")
if [ -z "$PRESENTATION_FOLDER" ]; then
  echo "Error: No presentation folder found. PDF generation aborted." > "$LOG_FILE"
  exit 1
fi

PRESENTATION_URL="http://localhost/$PRESENTATION_FOLDER/presentation.html"
PDF_OUTPUT="/usr/share/nginx/html/$PRESENTATION_FOLDER/presentation.pdf"

echo "Waiting for web server to be ready..."
for i in $(seq 1 60); do
  if curl -fsI --connect-timeout 2 --max-time 2 "$PRESENTATION_URL" >/dev/null; then
    echo "Web server is ready. Starting PDF generation..."
    cd /app && node pdf-generator.js \
      "$PRESENTATION_URL" \
      "$PDF_OUTPUT" \
      > "$LOG_FILE" 2>&1
    exit 0
  fi
  echo "Waiting for server... attempt $i/60"
  sleep 1
done

echo "Error: Web server failed to start. PDF generation aborted." > "$LOG_FILE"
exit 1
