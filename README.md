# Not Another PowerPoint Presentation
OR
# Yet Another PowerPoint Alternative

This guide walks you through setting up and using a custom Pandoc converter to transform ReStructuredText (`.rst`) documents into interactive HTML presentations using Reveal.js, viewable directly in your web browser.

## Setup and Preparation

### Building the Pandoc Converter Docker Image

To convert `.rst` files into HTML presentations, we first need to build the Docker image for the Pandoc converter. Navigate to the `pandoc-converter` directory and run the Docker build command:

```bash
cd pandoc-converter
docker build -t pandoc-converter .
cd ..
```

This command builds a Docker image named pandoc-converter based on the Dockerfile located in the pandoc-converter directory.

# Creating and Viewing Your Presentation
## Running the Web Server

Start an Nginx web server to serve your HTML presentation files. This server will host the converted presentation and make it accessible through your browser:
```bash
docker run --rm -v "$(pwd):/usr/share/nginx/html:ro" -p 8080:80 -d --name presentation-nginx nginx
```

This command mounts the current directory to the Nginx web root as a read-only volume and forwards port 8080 on your local machine to port 80 on the container, and ensures the container is removed upon stopping.

## Converting `.rst` Files to an HTML Presentation

Use the pandoc-converter Docker container to convert your .rst document into an HTML presentation powered by Reveal.js:

```bash
docker run --rm -v "$(pwd):/data" pandoc-converter -s -t revealjs -o /data/presentation.html /data/presentation.rst -V revealjs-url=./reveal.js

# Or to use a different theme
docker run --rm -v "$(pwd):/data" pandoc-converter -s -t revealjs -o /data/presentation.html /data/presentation.rst -V revealjs-url=./reveal.js -V theme=solarized

# Or to use a custom-style.css file for setting the background image:
docker run --rm -v "$(pwd):/data" pandoc-converter -s -t revealjs -o /data/presentation.html /data/presentation.rst -V revealjs-url=./reveal.js -V theme=white --css custom-style.css
```

This command takes presentation.rst from your current directory, converts it to presentation.html using the Reveal.js format, and outputs the file back to your current directory.

## Viewing the Presentation

Open your preferred web browser and navigate to http://localhost:8080/presentation.html. You should now see your presentation rendered as an interactive slide show. Navigate through the slides using the arrow keys on your keyboard.

## PDF version

To obtain the pdf version of it, visit http://localhost:8080/presentation.html?print-pdf, then press `CTRL` + `p` and select "Save as PDF".
