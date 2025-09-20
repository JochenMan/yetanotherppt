#!/bin/sh
# Waits for the web server to be ready, then generates the PDF.
LOG_FILE="/usr/share/nginx/html/pdf-generation.log"

echo "Waiting for web server to be ready..."
for i in $(seq 1 60); do
  if curl -fsI --connect-timeout 2 --max-time 2 http://127.0.0.1/presentation.html >/dev/null; then
    echo "Web server is ready. Starting PDF generation..."
    cd /app && node pdf-generator.js \
      http://localhost/presentation.html \
      /usr/share/nginx/html/presentation.pdf \
      > "$LOG_FILE" 2>&1
    exit 0
  fi
  echo "Waiting for server... attempt $i/60"
  sleep 1
done

echo "Error: Web server failed to start. PDF generation aborted." > "$LOG_FILE"
exit 1
