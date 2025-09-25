# Yet Another PowerPoint

Transform Markdown (.md) or ReStructuredText (.rst) documents into HTML presentations with Pandoc and Reveal.js. PDF export is handled by Puppeteer with Chromium, and both outputs are served locally. When you edit the source file, the HTML and PDF are automatically rebuilt.

## Quick Install

**Requirements:** Docker

**One command install:**
```bash
curl -fsSL https://raw.githubusercontent.com/jochenman/yetanotherppt/main/install.sh | bash
```

This clones the repo into a temporary directory, builds the yappt container, and creates ~/.local/bin/present. The script starts the container, renders and serves your presentation, and automatically rebuilds on file changes.

## Usage

Create a simple presentation:

````bash
cat > slides.md <<'EOF'
% Presentation Title
% Your Name
% Today's Date

# First Slide Title

- If you change the presentation file
- refresh the browser to see the changes in both
  - the html
  - and the pdf!

**Bold text** and *italic text* for emphasis.

---

# Second Slide Title

![Sample Image](https://picsum.photos/600/400)

(This uses a placeholder image from https://picsum.photos – replace it with your own.)

---

# Third Slide Title

Here's a block of code:

```python
def hello_world():
    print("Hello, world!")
```
EOF
````

**Customizing Your Presentation**

You can easily override the default background and styling. Just place a `background.jpg` or `custom-style.css` file in the same directory as your `slides.md` file. These local versions will be used automatically.

---

Render and host the .html to present/download the .pdf
```bash
present slides.md
```

**Live editing:** Edit `slides.md` while `present` is running - changes appear when you refresh your browser.

**Options:**
```bash
present slides.md --theme black --port 8080 # Default options
```

Supports both Markdown (.md) and ReStructuredText (.rst) files.

**Available themes:** `white`, `black`, `league`, `beige`, `sky`, `night`, `serif`, `simple`, `solarized`, `blood`, `moon`

## Uninstall

```bash
present --uninstall
```

## Customize and Build Your Own

To modify the background image or CSS styling:

```bash
git clone --recursive https://github.com/jochenman/yetanotherppt.git
cd yetanotherppt

# Edit custom-style.css or replace background.jpg with your own
# Then (re-)build and install your customized version
./uninstall.sh && ./install.sh
```
