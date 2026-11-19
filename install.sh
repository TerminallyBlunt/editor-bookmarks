#!/usr/bin/env bash
# EditorBookmarks installer
# shellcheck source-path=SCRIPTDIR

set -e
if (( $# )); then
    printf 'Usage: ./install.sh\n' >&2
    exit 1
fi
source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
# Reuse the uninstaller's paths and ownership checks.
# shellcheck source=uninstall.sh
source "$source_dir/uninstall.sh"

source_files=(eb completions/eb.bash completions/_eb completions/eb.fish)
if exists "$launcher" && ! owns_launcher; then
    printf 'Install stopped. The launcher already exists at %s.\n' "$launcher" >&2
    exit 1
fi
for index in "${!source_files[@]}"; do
    from=$source_dir/${source_files[index]}
    destination=${installed_files[index]}
    signature=${ownership_lines[index]}
    if ! owns_file "$from" "$signature"; then
        printf 'Install stopped. Expected a source file at %s.\n' "$from" >&2
        exit 1
    fi
    if exists "$destination" && ! owns_file "$destination" "$signature"; then
        printf 'Install stopped. An unrelated file already exists at %s.\n' "$destination" >&2
        exit 1
    fi
done

action=Installed
if exists "$application"; then
    action=Updated
fi

trap 'if [[ ${staged-} ]]; then rm -f -- "$staged"; fi' EXIT
for index in "${!source_files[@]}"; do
    destination=${installed_files[index]}
    directory=${destination%/*}
    mkdir -p -- "$directory"
    staged=$(mktemp -- "$directory/.eb-install.XXXXXXXX")
    mode=644
    (( index != 0 )) || mode=755
    install -m "$mode" -- "$source_dir/${source_files[index]}" "$staged"
    mv -fT -- "$staged" "$destination"
    staged=
done
mkdir -p -- "${launcher%/*}"
if ! owns_launcher; then
    ln -sT -- "$application" "$launcher"
fi

printf '%s EditorBookmarks at %s\n' "$action" "$application"
case :$PATH: in
    *:"$HOME/.local/bin":*) ;;
    *)
        printf '%s\n' 'To add ~/.local/bin to PATH, put the following in your Bash or Zsh startup file:'
        # shellcheck disable=SC2016
        printf '%s\n' '  export PATH="$HOME/.local/bin:$PATH"'
        printf '%s\n' 'For Fish, run: fish_add_path ~/.local/bin'
        printf '%s\n' 'See README.md for a shell alias alternative.'
        ;;
esac
completion_rule='======================'
printf '\n%s\n%s\n' 'Shell Completion Setup' "$completion_rule"
printf '%s\n' 'Bash: Start a new shell with bash-completion enabled, or source the completion file:'
printf '  source %q\n' "${installed_files[1]}"
printf '\n%s\n' 'Zsh: Add these lines to ~/.zshrc before any existing compinit invocation:'
# shellcheck disable=SC2016
printf '  fpath=(%q "${fpath[@]}")\n' "${installed_files[2]%/*}"
printf '%s\n' '  autoload -Uz compinit && compinit'
printf '\n%s\n%s\n' 'Fish: Start a new shell to load completions automatically.' "$completion_rule"
printf '\n%s\n' 'After editing a startup file, open a new shell. Try eb -h.'
printf '%s\n' 'See README.md for more details.'
