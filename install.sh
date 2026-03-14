#!/bin/bash
# install.sh - Installer for asl3-repeater-control
#
# Installs repeater-control.sh to:
#   /etc/asterisk/scripts/asl3-repeater-control/
#
# Creates a system-wide symlink at:
#   /usr/local/bin/repeater
#
# Must be run as root from the cloned repo directory.

set -e

INSTALL_DIR="/etc/asterisk/scripts/asl3-repeater-control"
SYMLINK="/usr/local/bin/repeater"
SCRIPT_NAME="repeater-control.sh"

# --- Root check ---

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This installer must be run as root."
    echo "Try: sudo bash install.sh"
    exit 1
fi

# --- Source file check ---

if [ ! -f "$SCRIPT_NAME" ]; then
    echo "Error: $SCRIPT_NAME not found."
    echo "Run install.sh from inside the cloned asl3-repeater-control directory."
    exit 1
fi

echo "============================================"
echo "   asl3-repeater-control Installer"
echo "============================================"
echo

# --- Dependency check ---

echo "Checking dependencies..."
MISSING=""
for dep in asterisk asl-tts; do
    if command -v "$dep" &>/dev/null; then
        echo "  [OK]  $dep"
    else
        echo "  [!!]  $dep  <-- not found"
        MISSING="$MISSING $dep"
    fi
done

if [ -n "$MISSING" ]; then
    echo
    echo "Warning: Missing packages:$MISSING"
    echo "Install with: apt install$MISSING"
    echo
    echo "The script will install, but TTS announcements will not work"
    echo "until the missing packages are installed."
    echo
fi

# --- Install ---

echo "Installing to $INSTALL_DIR ..."
mkdir -p "$INSTALL_DIR"
cp "$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME"
chown root:asterisk "$INSTALL_DIR/$SCRIPT_NAME"
chmod 750 "$INSTALL_DIR/$SCRIPT_NAME"
echo "  Script installed."

# --- Symlink ---

if [ -L "$SYMLINK" ]; then
    echo "Updating existing symlink at $SYMLINK ..."
    ln -sf "$INSTALL_DIR/$SCRIPT_NAME" "$SYMLINK"
elif [ -e "$SYMLINK" ]; then
    echo "Error: $SYMLINK already exists and is not a symlink."
    echo "Remove it manually and re-run the installer."
    exit 1
else
    echo "Creating symlink $SYMLINK -> $INSTALL_DIR/$SCRIPT_NAME ..."
    ln -s "$INSTALL_DIR/$SCRIPT_NAME" "$SYMLINK"
fi

echo "  Symlink created."
echo

echo "============================================"
echo "   Installation Complete"
echo "============================================"
echo
echo "Usage (run as root or asterisk user):"
echo
echo "  repeater Enable [NodeNumber]"
echo "  repeater Disable [NodeNumber]"
echo
echo "If NodeNumber is omitted, the first node in rpt.conf is used."
echo "You may also set the NODE1 environment variable as a default."
echo
