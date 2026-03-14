# asl3-repeater-control

A bash script to enable or disable an [ASL3](https://allstarlink.org/) (AllStar Link 3) repeater node.

**When disabled:** TX is shut down, all linked nodes are disconnected, linking is turned off, and telemetry is silenced. The node continues to receive signals and respond to DTMF commands.

**When enabled:** all functions are restored.

Announcements ("Repeater enabled." / "Repeater disabled.") are made via **text-to-speech (TTS)** — no pre-recorded audio files are required.

---

## Requirements

- ASL3 installed and configured
- `asterisk` — included with ASL3
- `asl-tts` — included with ASL3; provides TTS announcements via the piper engine

---

## Installation

Run this single command on your ASL3 server as root or with sudo:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/N6LKA/asl3-repeater-control/main/install.sh)
```

The installer:
- Downloads `repeater-control.sh` directly from GitHub
- Installs it to `/etc/asterisk/scripts/asl3-repeater-control/`
- Sets ownership to `root:asterisk` so both root and the asterisk user can run it
- Creates a symlink at `/usr/local/bin/repeater` so the command is available system-wide without specifying a path

If a previous installation is detected, the installer will prompt before updating and create a backup automatically.

---

## Usage

Must be run as **root** or the **asterisk** user.

```bash
# Enable the repeater (auto-detects node from rpt.conf)
repeater Enable

# Disable the repeater (auto-detects node from rpt.conf)
repeater Disable

# Specify a node number explicitly
repeater Enable 501260
repeater Disable 501260
```

You can also set the `NODE1` environment variable to define a default node:

```bash
export NODE1=501260
repeater Disable
```

If no node number is provided and `NODE1` is not set, the first node found in `/etc/asterisk/rpt.conf` is used automatically.

---

## What Each Command Does

### Enable
1. Enables repeater TX (`cop 2`)
2. Enables linking (`cop 11`)
3. Reconnects previously disconnected nodes (`ilink 16`)
4. Enables local telemetry on demand (`cop 35`)
5. Plays TTS announcement: *"Repeater enabled."*
6. Plays repeater ID (`status 11`)

### Disable
1. Disables local telemetry (`cop 34`)
2. Disconnects all linked nodes (`ilink 6`)
3. Disables linking (`cop 12`)
4. Plays TTS announcement: *"Repeater disabled."*
5. Plays repeater ID (`status 11`)
6. Waits 8 seconds for audio to complete over the air
7. Disables repeater TX (`cop 3`)

---

## Updating

To update to the latest version, run the same install command:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/N6LKA/asl3-repeater-control/main/install.sh)
```

The installer will detect the existing installation, prompt for confirmation, and create a backup before updating.

---

## License

MIT License — see [LICENSE](LICENSE) for details.
