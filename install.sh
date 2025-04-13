#!/bin/bash

# Configuration
APP_NAME="macindock"
REPO_URL="https://github.com/JonsonsHub"
TMP_DIR="/tmp/$APP_NAME-install"

# Styling
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

# Exit if any command fails
set -e

# Auto-detect current user
USERNAME=$(whoami)
USER_HOME="/Users/$USERNAME"
INSTALL_DIR="$USER_HOME/$APP_NAME"

# Clean screen
clear
echo -e "${BOLD}${GREEN}"
echo "=============================================="
echo "       $APP_NAME - Installation Script"
echo "=============================================="
echo -e "${NC}${NORMAL}"

# Confirm installation
echo -e "The application will be installed to:"
echo -e "${BOLD}$INSTALL_DIR${NORMAL}"
read -p "Do you want to continue? [y/N]: " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo -e "${YELLOW}Installation cancelled.${NC}"
    exit 0
fi

# Check for required tools
for tool in git make; do
    if ! command -v $tool &> /dev/null; then
        echo -e "${RED}✗ Required tool '$tool' is not installed.${NC}"
        exit 1
    fi
done

# Remove previous installation if it exists
if [ -d "$INSTALL_DIR" ]; then
    echo -e "\n${YELLOW}Warning:${NC} '$INSTALL_DIR' already exists."
    read -p "Do you want to remove it before proceeding? [y/N]: " OVERWRITE
    if [[ "$OVERWRITE" != "y" && "$OVERWRITE" != "Y" ]]; then
        echo -e "${YELLOW}Installation cancelled.${NC}"
        exit 0
    fi
    echo -e "${YELLOW}→ Removing: $INSTALL_DIR${NC}"
    rm -rf "$INSTALL_DIR"
    echo -e "${GREEN}✓ Previous installation removed.${NC}"
fi

# Create temporary directory
echo -e "\n${BLUE}→ Creating temporary build directory: $TMP_DIR${NC}"
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

# Clone repository
echo -e "${BLUE}→ Cloning repository: $REPO_URL${NC}"
git clone "$REPO_URL" "$TMP_DIR" >/dev/null 2>&1
echo -e "${GREEN}✓ Repository cloned.${NC}"

# Build with Makefile
cd "$TMP_DIR"
echo -e "${BLUE}→ Building application using Makefile...${NC}"
if [ ! -f Makefile ]; then
    echo -e "${RED}✗ Makefile not found in repository.${NC}"
    exit 1
fi
make >/dev/null 2>&1
echo -e "${GREEN}✓ Build successful.${NC}"

# Install app
echo -e "${BLUE}→ Installing to: $INSTALL_DIR${NC}"
mkdir -p "$INSTALL_DIR"
if [ -f "$TMP_DIR/build/$APP_NAME" ]; then
    cp -R "$TMP_DIR/build/$APP_NAME" "$INSTALL_DIR/"
    echo -e "${GREEN}✓ Copied from build/ directory.${NC}"
elif [ -f "$TMP_DIR/$APP_NAME" ]; then
    cp -R "$TMP_DIR/$APP_NAME" "$INSTALL_DIR/"
    echo -e "${GREEN}✓ Copied from root directory.${NC}"
else
    echo -e "${RED}✗ Application binary not found.${NC}"
    exit 1
fi

# Add to login items (autostart)
echo -e "${BLUE}→ Adding to login items...${NC}"
osascript <<EOF
tell application "System Events"
    if not (exists login item "$APP_NAME") then
        make new login item at end with properties {path:"$INSTALL_DIR/$APP_NAME", hidden:true}
    end if
end tell
EOF
echo -e "${GREEN}✓ Login item created.${NC}"

# Final success message
echo -e "\n${GREEN}${BOLD}✓ Installation complete!${NC}${NORMAL}"
echo -e "${BOLD}Installed to:${NC} $INSTALL_DIR"
echo -e "${BOLD}Auto-start enabled:${NC} Yes (on login)"
echo
