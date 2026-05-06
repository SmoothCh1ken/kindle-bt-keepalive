# Release v2.0 - KUAL Integration 🎉

## 🚀 Major Update: Point & Click Bluetooth Management

This release introduces full **KUAL integration** - no more SSH or KTerm needed after initial setup!

### ✨ New Features

- **KUAL Menu Integration**: Full graphical menu via Kindle Unified Application Launcher
- **Get MAC Address**: One-click device detection - no more manual MAC hunting
- **Three Operating Modes**:
  - **Reading Mode**: Perfect for audiobooks and ambient sounds (preserves battery)
  - **Always On**: iPod-style continuous playback (defers sleep when needed)
  - **Default (Disable)**: Restores your Kindle to vanilla state, removes all background processes
- **Persistent Configuration**: Settings survive reboots via Upstart
- **Single Config File**: Only one file to edit (`btkeepalive.conf`)
- **Pillow Notifications**: Visual feedback on every mode change

### 📁 Project Restructuring

```
kindle-bt-keepalive/
├── btkeepalive/           ← Copy to /mnt/us/btkeepalive/
│   ├── always-on/
│   ├── reading-mode/
│   ├── bin/
│   └── btkeepalive.conf  ← Just edit your MAC here
└── extensions/            ← Copy to /mnt/us/extensions/
    └── btkeepalive/      ← KUAL menu appears automatically
```

### 🔧 Technical Improvements

- **Immediate Start**: Services start right after clicking KUAL menu (no reboot needed)
- **Clean Disable**: Removes Upstart jobs, kills all processes, restores vanilla Kindle
- **Smarter MAC Detection**: Parses `/var/local/zbluetooth/bt_config.conf` for accurate device identification
- **Respawn Protection**: Upstart limited to 5 retries to prevent system strain

### 📖 Updated Documentation

- Rationale & Inspiration section moved to top
- **Before You Start** section: Pairing instructions before download
- Windows user-friendly instructions (drag-and-drop to Kindle drive)
- Hyperlinked sections for easy navigation
- List of text editors for every platform (Windows, Linux, macOS, Kindle)

### 🎨 Assets

- Project logos included (light/dark mode support)
- MIT License
- Complete acknowledgements to @notmarek, @kbarni, and KUAL Team

---

## Installation

1. Download and extract the ZIP
2. Copy `btkeepalive/` to `/mnt/us/` on your Kindle
3. Copy `extensions/` to `/mnt/us/` on your Kindle
4. Pair your Bluetooth device: **Settings → Bluetooth**
5. Click **"Get MAC Address"** in KUAL menu
6. Edit `/mnt/us/btkeepalive/btkeepalive.conf` with the shown MAC
7. Select **Reading Mode** or **Always On** - enjoy!

---

**Tested on**: Kindle Paperwhite 11th Generation, firmware 5.18.5.0.1

**Requirements**: Jailbroken Kindle with KUAL installed.

---

*Designed, drawn and programmed with ❤️ and 📚 for all readers everywhere.*
