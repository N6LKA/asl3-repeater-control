#!/bin/bash
# asl3-repeater-control - Enable or Disable an ASL3 repeater node
#
# When disabled: TX is off, links disconnected, linking and telemetry off.
# The node continues to receive signals and respond to DTMF commands.
# When enabled: all functions are restored.
#
# Announcements are made via asl-tts (included with ASL3).
#
# Usage: repeater enable|disable <NodeNumber>
#
# Must be run as root or the asterisk user.

ASTERISK="/usr/sbin/asterisk"

# --- Argument Parsing ---

# Normalize to lowercase for case-insensitive matching
cmd1="${1,,}"
node="$2"

if [ "$cmd1" != "enable" ] && [ "$cmd1" != "disable" ]; then
    echo "Error: First argument must be 'enable' or 'disable'."
    echo "Usage: $(basename "$0") enable|disable <NodeNumber>"
    exit 1
fi

if [ -z "$node" ]; then
    echo "Error: Node number is required."
    echo "Usage: $(basename "$0") enable|disable <NodeNumber>"
    exit 1
fi

echo "Command: $cmd1"
echo "Node:    $node"

# --- TTS Announcement ---

play_announcement() {
    local text="$1"

    if ! command -v asl-tts &>/dev/null; then
        echo "Warning: asl-tts not found. Install with: apt install asl-tts"
        return 1
    fi

    # asl-tts must run as the asterisk user
    if [ "$(id -u)" -eq 0 ]; then
        sudo -u asterisk asl-tts -n "$node" -t "$text"
    else
        asl-tts -n "$node" -t "$text"
    fi
}

# --- Enable ---

if [ "$cmd1" = "enable" ]; then

    # Enable TX
    $ASTERISK -rx "rpt cmd $node cop 2"
    echo "Repeater TX Enabled"

    # Enable Linking
    $ASTERISK -rx "rpt cmd $node cop 11"
    echo "Linking Enabled"

    # Reconnect previously disconnected nodes
    $ASTERISK -rx "rpt cmd $node ilink 16"
    echo "Reconnecting previously disconnected nodes."

    # Enable Local Telemetry Output on Demand
    $ASTERISK -rx "rpt cmd $node cop 35"
    echo "Telemetry Enabled"

    # TTS Announcement
    echo "Playing Announcement"
    play_announcement "Repeater enabled."

    # Play Repeater ID
    echo "Playing Repeater ID"
    $ASTERISK -rx "rpt cmd $node status 11"

fi

# --- Disable ---

if [ "$cmd1" = "disable" ]; then

    # Disable Local Telemetry Output
    $ASTERISK -rx "rpt cmd $node cop 34"
    echo "Telemetry Disabled"

    # Disconnect all links
    echo "Disconnecting other nodes."
    $ASTERISK -rx "rpt cmd $node ilink 6"

    # Disable Linking
    $ASTERISK -rx "rpt cmd $node cop 12"
    echo "Linking Disabled"

    # TTS Announcement
    echo "Playing Announcement"
    play_announcement "Repeater disabled."

    # Play Repeater ID
    echo "Playing Repeater ID"
    $ASTERISK -rx "rpt cmd $node status 11"

    sleep 8

    # Disable TX
    $ASTERISK -rx "rpt cmd $node cop 3"
    echo "Repeater TX Disabled"

fi
