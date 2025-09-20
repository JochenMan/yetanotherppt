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

After installation, use `present` from any directory:

```bash
# Auto-detect presentation.md/rst or slides.md/rst
present

# Convert specific file
present myfile.md

# With custom theme
present --theme solarized

# Full options
present myfile.rst --theme black --port 9000
```

**Available themes:** `white`, `black`, `league`, `beige`, `sky`, `night`, `serif`, `simple`, `solarized`, `blood`, `moon`

## File Structure

Your presentation directory stays **completely clean**:
```
my-presentation/
├── presentation.md     # Your slides (or .rst)
└── images/            # Any images you reference
```

*After running `present`:*
```
my-presentation/
├── presentation.md     # Your original file
├── presentation.html   # Generated presentation
└── images/            # Your images (copied to presentation)
```

**No reveal.js, no CSS files, no clutter!** Everything stays inside the Docker container.

## Quick Start Example

1. **Create a new presentation:**
   ```bash
   mkdir my-talk && cd my-talk
   echo "# My Presentation

   ## Slide 1
   Hello world!

   ## Slide 2
   This is easy!" > presentation.md
   ```

2. **Generate and serve:**
   ```bash
   present
   ```

3. **View:** http://localhost:8080/presentation.html

4. **Stop:** `docker stop yetanotherppt-presenter`

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
