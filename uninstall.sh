#!/bin/bash

# Configuration
APP_NAME="macindock"
USER_HOME="/Users/$(whoami)"
INSTALL_DIR="$USER_HOME/$APP_NAME"

# Styling
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

clear
echo -e "${BOLD}${GREEN}"
echo "=============================================="
echo "       $APP_NAME - Uninstallation Script"
echo "=============================================="
echo -e "${NC}${NORMAL}"

# Check if app is installed
if [ -d "$INSTALL_DIR" ]; then
    echo -e "This will remove the application from:"
    echo -e "${BOLD}$INSTALL_DIR${NORMAL}"
    read -p "Are you sure you want to uninstall? [y/N]: " CONFIRM
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        echo -e "${YELLOW}Uninstallation cancelled.${NC}"
        exit 0
    fi

    # Remove app files
    echo -e "${RED}→ Removing: $INSTALL_DIR${NC}"
    rm -rf "$INSTALL_DIR"
    echo -e "${GREEN}✓ Application files removed.${NC}"

    # Remove from login items
    echo -e "${RED}→ Removing from login items...${NC}"
    osascript <<EOF
tell application "System Events"
    if (exists login item "$APP_NAME") then
        delete login item "$APP_NAME"
    end if
end tell
EOF
    echo -e "${GREEN}✓ Login item removed.${NC}"

    echo -e "\n${GREEN}${BOLD}✓ Uninstallation complete!${NC}${NORMAL}"
else
    echo -e "${YELLOW}✗ Application not found at:$INSTALL_DIR${NC}"
    exit 1
fi
