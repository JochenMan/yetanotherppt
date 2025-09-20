#!/bin/bash

echo "Uninstalling yetanotherppt..."

# Stop any running containers
docker stop yetanotherppt-presenter 2>/dev/null || true

# Remove Docker image
docker rmi yetanotherppt/presenter 2>/dev/null || true

# Remove global command
if [ -f "$HOME/.local/bin/present" ]; then
    rm "$HOME/.local/bin/present"
    echo "Removed ~/.local/bin/present"
fi

echo "yetanotherppt uninstalled successfully!"