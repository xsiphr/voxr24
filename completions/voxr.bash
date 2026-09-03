#!/usr/bin/env bash
#
# Bash completion script for voxr
# Repo: https://github.com/xsiphr/voxr24
#

_voxr_find_datadir() {
  if [ -n "${VOXR_DATA_DIR:-}" ] && [ -d "$VOXR_DATA_DIR" ]; then
    echo "$VOXR_DATA_DIR"
    return
  fi

  local bin_path
  bin_path="$(command -v voxr 2>/dev/null || true)"
  if [ -n "$bin_path" ]; then
    local real_dir
    real_dir="$(dirname "$(readlink -f "$bin_path" 2>/dev/null || echo "$bin_path")")"
    if [ -d "$real_dir/fetchers" ]; then
      echo "$real_dir"
      return
    fi
  fi

  if [ -d "/usr/share/voxr/fetchers" ]; then
    echo "/usr/share/voxr"
  elif [ -d "/usr/local/share/voxr/fetchers" ]; then
    echo "/usr/local/share/voxr"
  elif [ -d "$PWD/fetchers" ]; then
    echo "$PWD"
  fi
}

_voxr_completions() {
  local cur prev words cword
  _init_completion || return

  local datadir
  datadir="$(_voxr_find_datadir)"

  local commands="fetch color apply backup restore --help --version -h -v"
  local terminals="kitty alacritty ghostty foot"

  # Helper functions to get dynamic lists
  _get_layouts() {
    [ -n "$datadir" ] && [ -d "$datadir/fetchers" ] && \
      find "$datadir/fetchers" -name "*.jsonc" -exec basename {} .jsonc \; 2>/dev/null
  }

  _get_colors() {
    [ -n "$datadir" ] && [ -d "$datadir/colorschemes" ] && \
      find "$datadir/colorschemes" -name "*.conf" -exec basename {} .conf \; 2>/dev/null
  }

  _get_presets() {
    [ -n "$datadir" ] && [ -d "$datadir/presets" ] && \
      find "$datadir/presets" -name "*.json" -exec basename {} .json \; 2>/dev/null
  }

  _get_backups() {
    local bdir="${XDG_CONFIG_HOME:-$HOME/.config}/voxr/backups"
    [ -d "$bdir" ] && ls -1 "$bdir" 2>/dev/null
  }

  # Value completions based on previous flag
  case "$prev" in
    --fetch|-f)
      COMPREPLY=( $(compgen -W "$(_get_layouts)" -- "$cur") )
      return 0
      ;;
    --color|-c)
      COMPREPLY=( $(compgen -W "$(_get_colors)" -- "$cur") )
      return 0
      ;;
    --preset|-p)
      COMPREPLY=( $(compgen -W "$(_get_presets)" -- "$cur") )
      return 0
      ;;
    --terminal|-t)
      COMPREPLY=( $(compgen -W "$terminals" -- "$cur") )
      return 0
      ;;
  esac

  # Subcommand specific completion
  local cmd="${words[1]}"

  case "$cmd" in
    fetch)
      if [ "$cword" -eq 2 ]; then
        COMPREPLY=( $(compgen -W "list preview" -- "$cur") )
      elif [ "$cword" -ge 3 ] && [ "${words[2]}" = "preview" ]; then
        COMPREPLY=( $(compgen -W "$(_get_layouts)" -- "$cur") )
      fi
      return 0
      ;;
    color)
      if [ "$cword" -eq 2 ]; then
        COMPREPLY=( $(compgen -W "list preview" -- "$cur") )
      elif [ "$cword" -ge 3 ] && [ "${words[2]}" = "preview" ]; then
        COMPREPLY=( $(compgen -W "$(_get_colors)" -- "$cur") )
      fi
      return 0
      ;;
    apply)
      local apply_opts="--fetch --color --preset --terminal -f -c -p -t"
      COMPREPLY=( $(compgen -W "$apply_opts" -- "$cur") )
      return 0
      ;;
    restore)
      COMPREPLY=( $(compgen -W "$(_get_backups)" -- "$cur") )
      return 0
      ;;
  esac

  # Root command completion
  if [ "$cword" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
    return 0
  fi
}

complete -F _voxr_completions voxr
