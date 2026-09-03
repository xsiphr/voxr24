#!/usr/bin/env bash
#
# Kitty Terminal Adapter for voxr
# Implements apply_colors() and reload()
#

KITTY_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kitty"
KITTY_CONF="$KITTY_CONFIG_DIR/kitty.conf"
THEME_FILE="$KITTY_CONFIG_DIR/current-theme.conf"

# Ensure include current-theme.conf is present in kitty.conf
ensure_kitty_include() {
  mkdir -p "$KITTY_CONFIG_DIR"
  if [ ! -f "$KITTY_CONF" ]; then
    echo "include current-theme.conf" > "$KITTY_CONF"
  elif ! grep -Eq '^[[:space:]]*include[[:space:]]+(\./)?current-theme\.conf' "$KITTY_CONF"; then
    printf "\n# Added by voxr\ninclude current-theme.conf\n" >> "$KITTY_CONF"
  fi
}

apply_colors() {
  local scheme_file="$1"
  if [ ! -f "$scheme_file" ]; then
    echo "Error: Colorscheme file not found: $scheme_file" >&2
    return 1
  fi

  mkdir -p "$KITTY_CONFIG_DIR"

  # Ensure base config includes current-theme.conf
  ensure_kitty_include

  # Write colorscheme to current-theme.conf
  cp "$scheme_file" "$THEME_FILE"

  # Try live update via kitty remote control if running inside Kitty
  if [ -n "${KITTY_WINDOW_ID:-}" ] || [ -n "${KITTY_PID:-}" ]; then
    if timeout -k 0.5s 0.5s kitty @ set-colors --all "$scheme_file" >/dev/null 2>&1; then
      echo "Applied live to running Kitty session via remote control."
      return 0
    fi
  fi

  echo "Applied to Kitty configuration ($THEME_FILE)."
  echo "Press Ctrl+Shift+F5 in Kitty (or restart terminal) to reload colors."
  return 0
}

reload() {
  if [ -n "${KITTY_WINDOW_ID:-}" ] || [ -n "${KITTY_PID:-}" ]; then
    if timeout -k 0.5s 0.5s kitty @ set-colors --all "$THEME_FILE" >/dev/null 2>&1; then
      echo "Reloaded Kitty colors live."
      return 0
    fi
  fi
  echo "Press Ctrl+Shift+F5 in Kitty to reload configuration."
}
