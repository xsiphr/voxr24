#compdef voxr
#
# Zsh completion script for voxr
# Repo: https://github.com/xsiphr/voxr24
#

_voxr_find_datadir() {
  if [ -n "${VOXR_DATA_DIR:-}" ] && [ -d "$VOXR_DATA_DIR" ]; then
    echo "$VOXR_DATA_DIR"
    return
  fi

  # Check relative to voxr command if found in path
  local bin_path
  bin_path="$(whence -p voxr 2>/dev/null || true)"
  if [ -n "$bin_path" ]; then
    local real_dir
    real_dir="$(dirname "$(realpath "$bin_path" 2>/dev/null || readlink -f "$bin_path" 2>/dev/null || echo "$bin_path")")"
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

_voxr_layouts() {
  local datadir
  datadir="$(_voxr_find_datadir)"
  local -a layouts
  if [ -n "$datadir" ] && [ -d "$datadir/fetchers" ]; then
    for f in "$datadir"/fetchers/*/*.jsonc(N); do
      local name="${f:t:r}"
      layouts+=("$name:System fetch layout")
    done
  fi
  _describe -t layouts 'fetch layout' layouts
}

_voxr_colors() {
  local datadir
  datadir="$(_voxr_find_datadir)"
  local -a colors
  if [ -n "$datadir" ] && [ -d "$datadir/colorschemes" ]; then
    for f in "$datadir"/colorschemes/*.conf(N); do
      local name="${f:t:r}"
      colors+=("$name:Terminal color palette")
    done
  fi
  _describe -t colors 'colorscheme' colors
}

_voxr_presets() {
  local datadir
  datadir="$(_voxr_find_datadir)"
  local -a presets
  if [ -n "$datadir" ] && [ -d "$datadir/presets" ]; then
    for f in "$datadir"/presets/*.json(N); do
      local name="${f:t:r}"
      presets+=("$name:Saved combo preset")
    done
  fi
  _describe -t presets 'preset' presets
}

_voxr_terminals() {
  local -a terms
  terms=(
    'kitty:Kitty terminal emulator'
    'alacritty:Alacritty terminal emulator'
    'ghostty:Ghostty terminal emulator'
    'foot:Foot Wayland terminal emulator'
  )
  _describe -t terminals 'terminal emulator' terms
}

_voxr_backups() {
  local backup_dir="${XDG_CONFIG_HOME:-$HOME/.config}/voxr/backups"
  local -a backups
  if [ -d "$backup_dir" ]; then
    for d in "$backup_dir"/*(N/); do
      local bname="${d:t}"
      backups+=("$bname:Backup snapshot")
    done
  fi
  _describe -t backups 'backup snapshot' backups
}

_voxr() {
  local context curcontext="$curcontext" state line
  typeset -A opt_args

  _arguments -C \
    '(-h --help)'{-h,--help}'[Show help information]' \
    '(-v --version)'{-v,--version}'[Show version information]' \
    '(-t --terminal)'{-t,--terminal}'[Specify terminal emulator]:terminal:_voxr_terminals' \
    '1:command:->command' \
    '*::options:->options'

  case $state in
    command)
      local -a subcommands
      subcommands=(
        'fetch:Manage system-info fetch layouts'
        'color:Manage terminal color palettes'
        'apply:Apply layout, colorscheme, or preset'
        'backup:Create backup snapshot of live configs'
        'restore:Restore configuration from backup'
      )
      _describe -t subcommands 'voxr command' subcommands
      ;;
    options)
      case $words[1] in
        fetch)
          _arguments -C \
            '1:subcommand:(list preview)' \
            '*:layout:_voxr_layouts'
          ;;
        color)
          _arguments -C \
            '1:subcommand:(list preview)' \
            '*:color:_voxr_colors'
          ;;
        apply)
          _arguments -C \
            '(-f --fetch)'{-f,--fetch}'[Apply fetch layout]:layout:_voxr_layouts' \
            '(-c --color)'{-c,--color}'[Apply terminal colorscheme]:colorscheme:_voxr_colors' \
            '(-p --preset)'{-p,--preset}'[Apply saved preset]:preset:_voxr_presets' \
            '(-t --terminal)'{-t,--terminal}'[Target terminal emulator]:terminal:_voxr_terminals'
          ;;
        restore)
          _arguments -C \
            '1:target:_voxr_backups'
          ;;
      esac
      ;;
  esac
}

_voxr "$@"
