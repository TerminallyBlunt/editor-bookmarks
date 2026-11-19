#!/usr/bin/env bash
# EditorBookmarks Bash completion

_eb_complete() {
    local helper=${XDG_DATA_HOME:-"$HOME/.local/share"}/editorbookmarks/eb
    local cur cword reply files=0
    local -a words
    COMPREPLY=()
    if declare -F _get_comp_words_by_ref >/dev/null; then
        _get_comp_words_by_ref -n ':=' cur words cword
    else
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
        cur=${words[cword]-}
    fi
    [[ -x $helper ]] || helper=$(type -P -- eb) || return 0
    words[cword]=$cur
    while IFS= read -r reply; do
        case $reply in
            files) files=1 ;;
            'name '*) COMPREPLY+=("${reply#name }") ;;
        esac
    done < <("$helper" --_complete "$((cword - 1))" "${words[@]:1}" 2>/dev/null)
    if (( files )); then
        if declare -F _filedir >/dev/null; then
            _filedir
        else
            local match
            while IFS= read -r match; do
                COMPREPLY+=("$match")
            done < <(compgen -f -- "$cur")
        fi
        compopt -o filenames
    fi
    return 0
}

complete -F _eb_complete eb
