# Yet Another PowerPoint

Transform Markdown (`.md`) or ReStructuredText (`.rst`) documents into beautiful interactive HTML presentations using Pandoc + Reveal.js. Since the built-in `?print-pdf` functionality of Reveal.js proved unreliable, PDF export is handled by Puppeteer, which uses Chromium to render `presentation.html` and capture each slide as a screenshot. **Pure Docker approach** – works from any directory with zero file system clutter!

## Quick Install

**Requirements:** Docker

**One command install:**
```bash
curl -fsSL https://raw.githubusercontent.com/jochenman/yetanotherppt/main/install.sh | bash
```

Or clone and install manually:
```bash
git clone --recursive https://github.com/jochenman/yetanotherppt.git
cd yetanotherppt
./install.sh
```

## Usage

Create a simple presentation:

```bash
echo "# My Presentation

## First Slide
Hello world!

## Second Slide
Edit this file and see changes instantly." > slides.md

present slides.md
```

**Live editing:** Edit `slides.md` while `present` is running - changes appear when you refresh your browser.

**Options:**
```bash
present slides.md --theme black --port 9000
present slides.rst --theme night --port 8000
```

Supports both Markdown (.md) and ReStructuredText (.rst) files.

**Available themes:** `white`, `black`, `league`, `beige`, `sky`, `night`, `serif`, `simple`, `solarized`, `blood`, `moon`

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/jochenman/yetanotherppt/main/uninstall.sh | bash
```

## Manual Docker Usage

If you prefer direct Docker commands:

```bash
# Build the image
docker build -t yetanotherppt/presenter .

# Run from any directory containing presentation.md
docker run --rm -d -v "$(pwd):/presentations:ro" -p 8080:80 yetanotherppt/presenter

# With options
docker run --rm -d -v "$(pwd):/presentations:ro" -p 9000:80 \
  yetanotherppt/presenter --file slides.md --theme black
```
