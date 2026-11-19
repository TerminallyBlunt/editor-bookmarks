#!/usr/bin/env bash
# EditorBookmarks uninstaller

data_home=${XDG_DATA_HOME:-"$HOME/.local/share"}
config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
application=$data_home/editorbookmarks/eb
launcher=$HOME/.local/bin/eb

declare -a installed_files=(
    "$application"
    "$data_home/bash-completion/completions/eb"
    "$data_home/zsh/site-functions/_eb"
    "$config_home/fish/completions/eb.fish"
)
declare -a ownership_lines=(
    '# EditorBookmarks application'
    '# EditorBookmarks Bash completion'
    '# EditorBookmarks Zsh completion'
    '# EditorBookmarks Fish completion'
)

exists() { [[ -e $1 || -L $1 ]]; }

owns_file() {
    [[ -f $1 && ! -L $1 ]] && [[ $(sed -n '2p; 2q' -- "$1") == "$2" ]]
}

owns_launcher() {
    [[ -L $launcher ]] && [[ $(readlink -- "$launcher") == "$application" ]]
}

uninstall() {
    local index path status=0
    if owns_launcher; then
        rm -- "$launcher" || status=1
    elif exists "$launcher"; then
        printf 'Left unrelated launcher at %s\n' "$launcher" >&2
    fi
    for index in "${!installed_files[@]}"; do
        path=${installed_files[index]}
        if owns_file "$path" "${ownership_lines[index]}"; then
            rm -- "$path" || status=1
        elif exists "$path"; then
            printf 'Left unrelated file at %s\n' "$path" >&2
        fi
    done
    if (( status )); then
        printf 'Some EditorBookmarks files could not be removed.\n' >&2
        return 1
    fi
    printf 'Uninstall finished. Bookmarks, settings and backup are preserved in %s.\n' "$config_home/editorbookmarks"
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    if (( $# )); then
        printf 'Usage: ./uninstall.sh\n' >&2
        exit 1
    fi
    uninstall
fi
