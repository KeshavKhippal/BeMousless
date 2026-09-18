# BeMousless

Yes, I know it is **Mousless**, not **Mouseless**. The spelling is intentional-ish.

Control the mouse from the numeric keypad with AutoHotkey v1. BeMousless supports Windows directly and Linux through Wine.

## Features

- Fluid, accelerated cursor movement with diagonal normalization
- Left click, right click, scrolling, precision movement, and orbit movement
- Persistent collect-and-drop dragging with Ctrl and the numeric keypad
- Pinned AutoHotkey `1.1.37.02` runtime
- Local, repeatable setup on Windows and Linux

## Quick start

These commands clone the public repository and start BeMousless.

### Windows PowerShell

```powershell
$repo = "https://github.com/KeshavKhippal/BeMousless.git"; $folder = "BeMousless"; git clone $repo $folder; Set-Location $folder; powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

Requirements: Windows, PowerShell, Git, and a numeric keypad. The installer downloads and verifies AutoHotkey `1.1.37.02` into `.tools`; it does not install AutoHotkey globally and does not require administrator access.

### Linux

```bash
repo="https://github.com/KeshavKhippal/BeMousless.git"; folder="BeMousless"; git clone "$repo" "$folder"; cd "$folder"; bash ./install.sh
```

The installer supports Debian/Ubuntu (`apt`), Fedora (`dnf`), and Arch (`pacman`). It installs Wine, `curl`, and `unzip` with `sudo` when required, verifies the pinned AutoHotkey archive, and starts it through Wine.

Linux requires a graphical desktop session and a working numeric keypad. AutoHotkey is Windows software, so Linux behavior depends on Wine and the desktop environment.

## Controls

Press `Numpad0 + Right` to enable or disable mouse mode. The mode tooltip also shows these controls:

| Keys | Action |
| --- | --- |
| `Numpad7/8/9`, `4/6`, `1/2/3` | Move the cursor |
| `Numpad5` | Left click, or drop a held item |
| `Numpad0` | Right click |
| `NumpadAdd` / `NumpadSub` | Scroll up/down |
| `NumpadDot` while moving | Precision movement |
| `Numpad0 + NumpadDot` | Orbit around the current point |
| `Ctrl + Numpad1/2/3/4/6/7/8/9` | Select and hold while moving |
| Release movement keys and Ctrl | Keep the selected item held |
| `Numpad5` at the destination | Drop the held item |
| `Ctrl + Alt + R` | Reload the script |
| `Ctrl + Alt + Q` | Exit the script |
| `Ctrl + Left/Right Shift` | Disable mouse mode |

### Collect and drop workflow

1. Enable mouse mode with `Numpad0 + Right`.
2. Hold Ctrl and a movement key, such as `Ctrl + Numpad6`, to select an item.
3. Release the movement key and Ctrl. The left mouse button remains held intentionally.
4. Move to the destination with the movement keys normally.
5. Press `Numpad5` to release the item.

Pressing `Numpad5` while no item is held performs an ordinary left click. If a drag becomes stuck, press `Numpad5` once to release it, or disable mouse mode with `Ctrl + Left Shift`.

## Running again

From the cloned repository:

Windows:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

Linux:

```bash
bash ./install.sh
```

To download and verify the Windows runtime without launching the script:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1 -NoLaunch
```

## Files and security

- `BeMousless.ahk`: the controller itself
- `setup.ps1`: Windows installer and launcher
- `install.sh`: Linux dependency installer and Wine launcher
- `.tools/`: downloaded runtime files, ignored by Git

Both installers pin AutoHotkey `1.1.37.02` and verify its SHA-256 checksum before extraction. The scripts download only from the official AutoHotkey GitHub release URL.

## Troubleshooting

- **No keys work:** enable mouse mode with `Numpad0 + Right`; confirm Num Lock and the numeric keypad are active.
- **A drag remains held:** press `Numpad5` or disable mouse mode with `Ctrl + Left Shift`.
- **Windows execution policy blocks setup:** run the documented command with `-ExecutionPolicy Bypass`.
- **Linux installer asks for a password:** it is using `sudo` to install Wine and command-line dependencies.
- **Linux has no tray icon:** stop the process with `pkill -f AutoHotkeyU32.exe`.
- **Linux input behaves differently:** verify that Wine can access the graphical desktop session and that the desktop environment exposes keypad events.

## License

Add the project license before publishing a release. The repository currently contains no license file, so usage and redistribution terms are not yet declared.
