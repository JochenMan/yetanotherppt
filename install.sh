#!/bin/bash
set -e

# yetanotherppt installer - Pure Docker approach
BIN_DIR="$HOME/.local/bin"
IMAGE_NAME="yetanotherppt/presenter"

echo "Installing yetanotherppt..."

# Create bin directory
mkdir -p "$BIN_DIR"

# Check if Docker is available
if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is required but not installed."
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

# Build the Docker image (since we're not publishing to registry yet)
echo "Building yetanotherppt Docker image..."

# For testing: use current directory instead of cloning
if [ -f "./Dockerfile" ] && [ -f "./entrypoint.sh" ]; then
    echo "Using local directory for testing..."
    docker build -t "$IMAGE_NAME" .
else
    # Production: clone from git
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    git clone --recursive https://github.com/jochenman/yetanotherppt.git .
    docker build -t "$IMAGE_NAME" .
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
fi

# Create global command
cat > "$BIN_DIR/present" << EOF
#!/bin/bash
# yetanotherppt pure Docker wrapper

IMAGE_NAME="$IMAGE_NAME"
CURRENT_DIR="\$(pwd)"

# Parse arguments
INPUT_FILE=""
THEME="black"
PORT="8080"

# Generate timestamp for unique folder
TIMESTAMP=\$(date +%s)
PRESENTATION_FOLDER="p-\$TIMESTAMP"

show_help() {
    echo "Yet Another PPT - Transform Markdown/RST to Beautiful Presentations"
    echo ""
    echo "Usage: present <file> [options]"
    echo ""
    echo "Arguments:"
    echo "  <file>           Markdown (.md) or ReStructuredText (.rst) file"
    echo ""
    echo "Options:"
    echo "  --theme THEME    Presentation theme (default: black)"
    echo "  --port PORT      Server port (default: 8080)"
    echo "  --uninstall      Remove yetanotherppt from system"
    echo "  -h, --help       Show this help message"
    echo ""
    echo "Available themes:"
    echo "  white, black, league, beige, sky, night, serif, simple, solarized, blood, moon"
    echo ""
    echo "Examples:"
    echo "  present slides.md"
    echo "  present presentation.rst --theme black --port 9000"
    echo ""
    echo "Live editing: Edit your source file while present is running - changes"
    echo "appear automatically when you refresh your browser."
}

while [ \$# -gt 0 ]; do
    case \$1 in
        -h|--help)
            show_help
            exit 0
            ;;
        --theme)
            THEME="\$2"
            shift 2
            ;;
        --port)
            PORT="\$2"
            shift 2
            ;;
        --uninstall)
            echo "Uninstalling yetanotherppt..."
            # Stop any running containers
            docker stop yetanotherppt-presenter 2>/dev/null || true
            # Remove Docker image
            docker rmi yetanotherppt/presenter 2>/dev/null || true
            # Remove this script
            rm "\$0"
            echo "yetanotherppt uninstalled successfully!"
            exit 0
            ;;
        *)
            if [ -z "\$INPUT_FILE" ]; then
                INPUT_FILE="\$1"
            fi
            shift
            ;;
    esac
done

# Stop any existing container
docker stop yetanotherppt-presenter 2>/dev/null || true

echo "Starting yetanotherppt presenter..."

# Show help if no input file specified
if [ -z "\$INPUT_FILE" ]; then
    show_help
    exit 1
fi

# Run the all-in-one container
docker run --rm -d \\
    --name yetanotherppt-presenter \\
    -v "\$CURRENT_DIR:/usr/share/nginx/html/presentations:ro" \\
    -p "\$PORT:80" \\
    "\$IMAGE_NAME" \\
    --file "\$INPUT_FILE" --theme "\$THEME" --folder "\$PRESENTATION_FOLDER" \\
    --css custom-style.css

# Wait a moment for container to start
sleep 2

echo "Presentation ready at: http://localhost:\$PORT/\$PRESENTATION_FOLDER/presentation.html"
echo "PDF version at: http://localhost:\$PORT/\$PRESENTATION_FOLDER/presentation.pdf"
EOF

chmod +x "$BIN_DIR/present"

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo ""
    echo "Add $HOME/.local/bin to your PATH by adding this line to your shell profile:"
    echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
    echo "Then reload your shell or run: source ~/.bashrc (or ~/.zshrc)"
fi

echo ""
echo "yetanotherppt installed successfully!"
echo ""
echo "Usage:"
echo "   present myfile.md # Or present myfile.rst"
echo "   present myfile.md --theme black --port 8080  # Default options"
echo ""
