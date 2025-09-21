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
THEME="white"
PORT="8080"

# Generate timestamp for unique folder
TIMESTAMP=\$(date +%s)
PRESENTATION_FOLDER="p-\$TIMESTAMP"

while [ \$# -gt 0 ]; do
    case \$1 in
        --theme)
            THEME="\$2"
            shift 2
            ;;
        --port)
            PORT="\$2"
            shift 2
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

# Run the all-in-one container
if [ -n "\$INPUT_FILE" ]; then
    docker run --rm -d \\
        --name yetanotherppt-presenter \\
        -v "\$CURRENT_DIR:/usr/share/nginx/html/presentations:ro" \\
        -p "\$PORT:80" \\
        "\$IMAGE_NAME" \\
        --file "\$INPUT_FILE" --theme "\$THEME" --folder "\$PRESENTATION_FOLDER" \\
        --css custom-style.css
else
    docker run --rm -d \\
        --name yetanotherppt-presenter \\
        -v "\$CURRENT_DIR:/usr/share/nginx/html/presentations:ro" \\
        -p "\$PORT:80" \\
        "\$IMAGE_NAME" \\
        --theme "\$THEME" --folder "\$PRESENTATION_FOLDER" \\
        --css custom-style.css
fi

# Wait a moment for container to start
sleep 2

echo "Presentation ready at: http://localhost:\$PORT/\$PRESENTATION_FOLDER/presentation.html"
echo "PDF version at: http://localhost:\$PORT/\$PRESENTATION_FOLDER/presentation.pdf"
echo ""
echo "Stop with: docker stop yetanotherppt-presenter"
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
echo "   present                    # Auto-detect presentation file"
echo "   present myfile.md          # Convert specific file"
echo "   present --theme black      # With custom theme"
echo "   present myfile.md --theme solarized --port 9000  # Full options"
echo ""
echo "Uninstall with: ~/.local/bin/present --uninstall"
