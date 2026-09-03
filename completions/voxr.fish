# Fish completion script for voxr
# Repo: https://github.com/xsiphr/voxr24

function __voxr_datadir
    if set -q VOXR_DATA_DIR; and test -d "$VOXR_DATA_DIR"
        echo "$VOXR_DATA_DIR"
        return
    end

    set -l bin (command -s voxr)
    if test -n "$bin"
        set -l dir (dirname (realpath "$bin" 2>/dev/null; or readlink -f "$bin" 2>/dev/null; or echo "$bin"))
        if test -d "$dir/fetchers"
            echo "$dir"
            return
        end
    end

    if test -d "/usr/share/voxr/fetchers"
        echo "/usr/share/voxr"
    else if test -d "$PWD/fetchers"
        echo "$PWD"
    end
end

function __voxr_layouts
    set -l dir (__voxr_datadir)
    if test -n "$dir"; and test -d "$dir/fetchers"
        find "$dir/fetchers" -name "*.jsonc" -exec basename {} .jsonc \; 2>/dev/null
    end
end

function __voxr_colors
    set -l dir (__voxr_datadir)
    if test -n "$dir"; and test -d "$dir/colorschemes"
        find "$dir/colorschemes" -name "*.conf" -exec basename {} .conf \; 2>/dev/null
    end
end

function __voxr_presets
    set -l dir (__voxr_datadir)
    if test -n "$dir"; and test -d "$dir/presets"
        find "$dir/presets" -name "*.json" -exec basename {} .json \; 2>/dev/null
    end
end

function __voxr_backups
    set -l bdir (test -n "$XDG_CONFIG_HOME"; and echo "$XDG_CONFIG_HOME/voxr/backups"; or echo "$HOME/.config/voxr/backups")
    if test -d "$bdir"
        ls -1 "$bdir" 2>/dev/null
    end
end

# Commands
complete -c voxr -f
complete -c voxr -n "__fish_use_subcommand" -a "fetch" -d "Manage fetch layouts"
complete -c voxr -n "__fish_use_subcommand" -a "color" -d "Manage terminal colorschemes"
complete -c voxr -n "__fish_use_subcommand" -a "apply" -d "Apply layout, color, or preset"
complete -c voxr -n "__fish_use_subcommand" -a "backup" -d "Create backup of configs"
complete -c voxr -n "__fish_use_subcommand" -a "restore" -d "Restore configuration from backup"
complete -c voxr -s h -l help -d "Show help"
complete -c voxr -s v -l version -d "Show version"
complete -c voxr -s t -l terminal -a "kitty alacritty ghostty foot" -d "Target terminal emulator"

# Subcommands: fetch
complete -c voxr -n "__fish_seen_subcommand_from fetch" -a "list" -d "List available layouts"
complete -c voxr -n "__fish_seen_subcommand_from fetch" -a "preview" -d "Preview a layout"
complete -c voxr -n "__fish_seen_subcommand_from fetch; and __fish_prev_arg_in preview" -a "(__voxr_layouts)"

# Subcommands: color
complete -c voxr -n "__fish_seen_subcommand_from color" -a "list" -d "List available colorschemes"
complete -c voxr -n "__fish_seen_subcommand_from color" -a "preview" -d "Preview color swatches"
complete -c voxr -n "__fish_seen_subcommand_from color; and __fish_prev_arg_in preview" -a "(__voxr_colors)"

# Subcommands: apply
complete -c voxr -n "__fish_seen_subcommand_from apply" -s f -l fetch -a "(__voxr_layouts)" -d "Apply fetch layout"
complete -c voxr -n "__fish_seen_subcommand_from apply" -s c -l color -a "(__voxr_colors)" -d "Apply terminal colorscheme"
complete -c voxr -n "__fish_seen_subcommand_from apply" -s p -l preset -a "(__voxr_presets)" -d "Apply saved preset"
complete -c voxr -n "__fish_seen_subcommand_from apply" -s t -l terminal -a "kitty alacritty ghostty foot" -d "Target terminal"

# Subcommands: restore
complete -c voxr -n "__fish_seen_subcommand_from restore" -a "(__voxr_backups)" -d "Select backup snapshot"
