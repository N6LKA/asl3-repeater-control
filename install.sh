#!/bin/bash
# =============================================================================
# install.sh - Installer for asl3-repeater-control
# https://github.com/N6LKA/asl3-repeater-control
# =============================================================================

INSTALL_DIR="/etc/asterisk/scripts"
SCRIPT_FILE="$INSTALL_DIR/repeater-control.sh"
SYMLINK="/usr/local/bin/repeater"
REPO="https://raw.githubusercontent.com/N6LKA/asl3-repeater-control/main"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "=============================================="
echo "  asl3-repeater-control - Installer"
echo "  https://github.com/N6LKA/asl3-repeater-control"
echo "=============================================="
echo ""

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}ERROR: This installer must be run as root or with sudo.${NC}"
    exit 1
fi

# --- Check for existing install ---
if [[ -f "$SCRIPT_FILE" ]]; then
    echo -e "${YELLOW}Existing installation detected. Updating...${NC}"
    BACKUP="$SCRIPT_FILE.bak.$(date +%Y%m%d%H%M%S)"
    cp "$SCRIPT_FILE" "$BACKUP"
    echo "Backup created: $BACKUP"
fi

echo ""
echo "--- Downloading files ---"

# --- Ensure install directory exists ---
mkdir -p "$INSTALL_DIR"

# --- Download main script ---
echo "Downloading repeater-control.sh..."
curl -fsSL "$REPO/repeater-control.sh" -o "$SCRIPT_FILE"
if [[ $? -ne 0 ]]; then
    echo -e "${RED}ERROR: Failed to download repeater-control.sh${NC}"
    if [[ -n "$BACKUP" && -f "$BACKUP" ]]; then
        echo "Restoring backup..."
        cp "$BACKUP" "$SCRIPT_FILE"
    fi
    exit 1
fi
chown root:asterisk "$SCRIPT_FILE"
chmod 750 "$SCRIPT_FILE"
echo "Script installed to: $SCRIPT_FILE"

# --- Create symlink ---
ln -sf "$SCRIPT_FILE" "$SYMLINK"
echo "Symlink created: $SYMLINK -> $SCRIPT_FILE"

# --- Clean up backup on success ---
[[ -n "$BACKUP" && -f "$BACKUP" ]] && rm -f "$BACKUP"

echo ""
echo "=============================================="
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Usage (run as root or asterisk user):"
echo ""
echo "  repeater Enable [NodeNumber]"
echo "  repeater Disable [NodeNumber]"
echo ""
echo "If NodeNumber is omitted, the first node in rpt.conf is used."
echo "You may also set the NODE1 environment variable as a default."
echo "=============================================="
echo ""
