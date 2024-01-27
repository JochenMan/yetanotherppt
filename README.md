# Not another PPT please
# OR
# Yet another PPT

# Run the webserver
docker run --name presentation-nginx -v $(pwd):/usr/share/nginx/html:ro -p 8080:80 -d nginx

# Build the pandoc converter
cd pandoc-converter
docker build -t pandoc-converter .
cd ..

# Convert the .rst files

docker run --rm -v "$(pwd):/data" pandoc-converter -s -t revealjs -o /data/presentation.html /data/presentation.rst -V revealjs-url=./reveal.js
