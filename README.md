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

## Installation & Updates

Run the following command as root or with sudo for both fresh installs and updates:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/N6LKA/asl3-repeater-control/main/install.sh)
```

**Fresh install:** Downloads `repeater-control.sh` directly from GitHub, installs it to `/etc/asterisk/scripts/`, sets ownership to `root:asterisk`, and creates a symlink at `/usr/local/bin/repeater` for system-wide access.

**Existing install detected:** The installer will automatically back up the existing script and download the latest version.

---

## Usage

Must be run as **root** or the **asterisk** user.

```bash
repeater enable 501260
repeater disable 501260
```

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

## License

MIT License — Copyright 2026 Larry K. Aycock (N6LKA)

See [LICENSE](LICENSE) for details.
