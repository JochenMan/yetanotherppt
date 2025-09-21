FROM nginx:alpine3.22

ARG PANDOC_VERSION=3.6.4-r0
RUN apk update && apk add --no-cache "pandoc-cli=${PANDOC_VERSION}" nodejs npm chromium inotify-tools

# Set Puppeteer to use system Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Copy reveal.js and styling assets into nginx web root
COPY reveal.js /usr/share/nginx/html/reveal.js
COPY custom-style.css /usr/share/nginx/html/custom-style.css
COPY background.jpg /usr/share/nginx/html/

# Create app directory and install Puppeteer
WORKDIR /app
RUN npm init -y && npm install puppeteer@21.6.1
COPY pdf-generator.js /app/pdf-generator.js

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy background PDF generator script
COPY generate-pdf-in-background.sh /generate-pdf-in-background.sh
RUN chmod +x /generate-pdf-in-background.sh

# Copy file watcher script
COPY file-watcher.sh /file-watcher.sh
RUN chmod +x /file-watcher.sh

# Expose port 80
EXPOSE 80

# Set working directory back to root for nginx
WORKDIR /

# Use custom entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD []
