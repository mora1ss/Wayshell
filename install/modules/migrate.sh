#!/usr/bin/env bash

get_compositor_config_dir_name() {
    local comp="$1"
    case "$comp" in
        hyprland) echo "hypr" ;;
        niri) echo "niri" ;;
        sway) echo "sway" ;;
        *) echo "$comp" ;;
    esac
}

backup_compositor_directory() {
    local comp="$1"
    local dir_name
    dir_name=$(get_compositor_config_dir_name "$comp")

    local COMP_DIR="$HOME/.config/$dir_name"
    local BACKUP_BASE="$HOME/.config/${dir_name}_backup"
    local BACKUP_DIR="$BACKUP_BASE/backup_$(date +%Y%m%d_%H%M%S)"

    if [ -d "$COMP_DIR" ] && [ "$(ls -A "$COMP_DIR" 2>/dev/null)" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -a "$COMP_DIR/." "$BACKUP_DIR/" 2>/dev/null || true
    fi
}

backup_compositors() {
    local compositors=("$@")
    for comp in "${compositors[@]}"; do
        backup_compositor_directory "$comp"
    done
}

migrate_one_path() {
    local src="$1"
    local dst="$2"
    if [ -e "$src" ] && [ ! -e "$dst" ]; then
        mkdir -p "$(dirname "$dst")"
        mv "$src" "$dst"
    fi
}

remove_old_bin_link() {
    local path="$1"
    if [ -L "$path" ]; then
        rm -f "$path" 2>/dev/null || sudo rm -f "$path" 2>/dev/null || true
    fi
}

migrate_brand_paths() {
    local cache="${XDG_CACHE_HOME:-$HOME/.cache}"

    migrate_one_path "$HOME/.config/serpantinum" "$HOME/.config/wayshell"
    migrate_one_path "$HOME/.config/hsh" "$HOME/.config/wayshell"
    migrate_one_path "$HOME/.local/share/serpantinum" "$HOME/.local/share/wayshell"
    migrate_one_path "$HOME/.local/share/hsh" "$HOME/.local/share/wayshell"
    migrate_one_path "$HOME/.local/state/serpantinum" "$HOME/.local/state/wayshell"
    migrate_one_path "$HOME/.local/state/hsh" "$HOME/.local/state/wayshell"
    migrate_one_path "$HOME/.cache/serpantinum" "$HOME/.cache/wayshell"
    migrate_one_path "$HOME/.cache/hsh" "$HOME/.cache/wayshell"
    migrate_one_path "$cache/serpantinum-wallpapers" "$cache/wayshell-wallpapers"
    migrate_one_path "$cache/hsh-wallpapers" "$cache/wayshell-wallpapers"
    migrate_one_path "$cache/serpantinum-installer" "$cache/wayshell-installer"
    migrate_one_path "$cache/hsh-installer" "$cache/wayshell-installer"

    local name
    for name in hsh hshd serpantinum serpantinumd; do
        remove_old_bin_link "$HOME/.local/bin/$name"
        remove_old_bin_link "/usr/local/bin/$name"
    done
}

migrate_legacy() {
    local compositors=("$@")
    pkill -f "settings_watcher.sh" 2>/dev/null || true
    pkill -f "hypr/scripts/quickshell" 2>/dev/null || true

    if pacman -Qq quickshell-git &>/dev/null; then
        paru -R --noconfirm quickshell-git 2>/dev/null || sudo pacman -Rdd --noconfirm quickshell-git 2>/dev/null || true
    fi

    backup_compositors "${compositors[@]}"

    if [ -f "$HOME/.local/state/imperative-dots-version" ]; then
        mkdir -p "$HOME/.config/hypr_backup"
        mv "$HOME/.local/state/imperative-dots-version" "$HOME/.config/hypr_backup/imperative-dots-version.bak" 2>/dev/null || true
    fi
}
