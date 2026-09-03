# voxr24 `v1.1.0`

A unified terminal aesthetics manager that gives you two independent, freely mixable knobs:
1. **System-info fetch layout** (the structure, modules, and order of data shown by fetch tools like `fastfetch`).
2. **Terminal colorscheme** (the 16-color ANSI palette + background/foreground rendered by your terminal emulator, like Kitty).

Both are controlled through a single, fast CLI: **`voxr`**.

---

## 💡 Why Decoupled?

Most fetch themes hardcode hex colors directly into their layouts, locking layout and palette together. In reality:
- Terminal colors belong to the terminal emulator.
- Fetch layouts that use standard ANSI color names (e.g. `cyan`, `magenta`, `green`) automatically inherit whatever colorscheme your terminal is running.

`voxr` decouples them cleanly: you can pick any fetch layout and pair it with any terminal colorscheme, or save your favorite combinations as presets.

---

## 📦 Installation

### Option 1: Arch Linux (AUR)
```bash
paru -S voxr-git
# or
yay -S voxr-git
```

### Option 2: Manual Clone (Portable Symlink or makepkg)
1. **Clone the repository:**
   ```bash
   git clone https://github.com/xsiphr/voxr24.git
   cd voxr24
   ```

2. **Run locally via user symlink (Portable mode):**
   ```bash
   mkdir -p ~/.local/bin
   ln -s "$(pwd)/voxr" ~/.local/bin/voxr
   ```
   *Ensure `~/.local/bin` is in your `$PATH` (e.g. in your `~/.zshrc` or `~/.bashrc`).*

   **Or install system-wide via pacman:**
   ```bash
   makepkg -si
   ```

---

## 🚀 Commands & Usage

### 1. Fetch Layouts (`voxr fetch`)

- **List available layouts:**
  ```bash
  voxr fetch list
  ```
- **Preview a layout (non-destructive, runs fastfetch without touching your config):**
  ```bash
  voxr fetch preview xsip
  voxr fetch preview tree
  voxr fetch preview compact
  ```

### 2. Terminal Colorschemes (`voxr color`)

- **List available colorschemes:**
  ```bash
  voxr color list
  ```
- **Preview palette swatches in your terminal:**
  ```bash
  voxr color preview fern
  voxr color preview nord
  voxr color preview catppuccin
  ```

### 3. Mix & Match Application (`voxr apply`)

- **Apply a layout and colorscheme independently or together:**
  ```bash
  # Mix any layout with any palette:
  voxr apply --fetch tree --color nord

  # Or apply just a layout:
  voxr apply --fetch compact

  # Or apply just a colorscheme:
  voxr apply --color fern
  ```

- **Apply a saved preset combo:**
  ```bash
  voxr apply --preset xsip
  ```

### 4. Backups & Safety (`voxr backup` / `voxr restore`)

`voxr` protects your existing setup and never silently overwrites your live files.
- **Create an explicit timestamped backup of both your fetch config and terminal theme:**
  ```bash
  voxr backup
  ```
- **Restore the latest (or a specific) backup:**
  ```bash
  voxr restore
  ```

---

## 🖥️ Scope & Supported Tools

- **Fetch Tool:** `fastfetch`
- **Supported Terminal Emulators:**
  - **`kitty`**: Live update via remote control or `current-theme.conf` (`adapters/kitty.sh`).
  - **`alacritty`**: Automatically maintains `current-theme.toml` with auto-reload (`adapters/alacritty.sh`).
  - **`ghostty`**: Live update via `current-theme` theme configuration (`adapters/ghostty.sh`).
  - **`foot`**: Wayland terminal support with dedicated `#`-stripped hex parser (`adapters/foot.sh`).

### 🔍 Automatic Terminal Detection
`voxr` automatically senses which terminal you are running by checking:
1. Environment variables (`$KITTY_PID`, `$ALACRITTY_LOG`, `$GHOSTTY_RESOURCES_DIR`, `$FOOT_SERVER_SOCKET_PATH`).
2. Terminal program tags (`$TERM_PROGRAM`).
3. `$TERM` variable (`xterm-kitty`, `alacritty`, `foot`, `xterm-ghostty`).
4. Parent process ancestry tree (`ps -o comm=`).

You can also explicitly target any terminal with `--terminal` or `-t`:
```bash
voxr apply --color nord --terminal alacritty
```

---

## ⚡ Shell Autocompletion

Dynamic tab completion is provided for **Zsh**, **Bash**, and **Fish**.

### Manual Activation (Portable / Local Clone)
- **Zsh:**
  Add the completions directory to your `fpath` before `compinit` in `~/.zshrc`:
  ```zsh
  fpath=(/path/to/voxr24/completions $fpath)
  autoload -Uz compinit && compinit
  ```
  *Or simply:*
  ```zsh
  source /path/to/voxr24/completions/voxr.zsh
  ```

- **Bash:**
  Add to your `~/.bashrc`:
  ```bash
  source /path/to/voxr24/completions/voxr.bash
  ```

- **Fish:**
  Symlink to your completions folder:
  ```fish
  ln -s /path/to/voxr24/completions/voxr.fish ~/.config/fish/completions/voxr.fish
  ```

*(When installed via AUR / `makepkg`, completions are installed to standard system paths and work automatically).*

---

## 🎨 Included Content

### Fetch Layouts (`fetchers/fastfetch/`)
- **`xsip`**: Clean minimal EndeavourOS/niri layout with custom spacing and OS life tracker.
- **`tree`**: Branch-style hierarchy (`├`, `└`) using adaptive ANSI colors that inherit your active terminal palette.
- **`compact`**: Dense, single-line overview with adaptive ANSI colors.

### Colorschemes (`colorschemes/`)
- **`fern`**: Authentic warm, earthy minimalism (sand `#d9a876`, mint `#8fd0b8`, ember `#ffc799`, dark `#101010`).
- **`nord`**: Arctic icy frost and slate tones.
- **`catppuccin`**: Soft pastel tones of Catppuccin Mocha.

### Presets (`presets/`)
- **`xsip`**: Pairs `fastfetch/xsip` with the `fern` terminal colorscheme.

---

## 🤝 Contributing

`voxr` is designed to be easily extensible. You can add new content without modifying the core `voxr` script:

### 1. Add a Fetch Layout
Drop a new `.jsonc` file into `fetchers/<tool>/` (e.g. `fetchers/fastfetch/minimal.jsonc`).
> **Tip:** Use named ANSI colors (`cyan`, `magenta`, `blue`, etc.) rather than hardcoded hex values so the layout dynamically adapts to any terminal colorscheme.

### 2. Add a Colorscheme
Drop a new `.conf` file into `colorschemes/` (e.g. `colorschemes/gruvbox.conf`).

### 3. Add a Preset
Create a JSON file in `presets/<preset-name>.json`:
```json
{
  "fetcher": "fastfetch/tree",
  "colorscheme": "nord"
}
```

### 4. Add a Terminal Adapter
Add a new adapter script under `adapters/<terminal>.sh` implementing two functions:
- `apply_colors <colorscheme_file>`
- `reload`

---

## 📄 License

MIT © [xsiphr](https://github.com/xsiphr)
