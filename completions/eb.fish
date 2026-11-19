# EditorBookmarks completion for Fish
# EditorBookmarks Fish completion

function __editorbookmarks_complete
    set -l helper "$HOME/.local/share/editorbookmarks/eb"
    if set -q XDG_DATA_HOME[1]; and test -n "$XDG_DATA_HOME"
        set helper "$XDG_DATA_HOME/editorbookmarks/eb"
    end
    if not test -x "$helper"
        set helper (type -P eb)
    end
    test -n "$helper"; or return

    set -l before (commandline -opc)
    set -l words (commandline -op)
    set -l current (count $before)
    set -l prefix (commandline -ct | string unescape --style=script)
    set -q prefix[1]; or set prefix ''
    set -l suffix
    set -l token (commandline -t | string collect)
    set -l next (math $current + 1)
    if set -q token[1]; and test -n "$token"
        set next (math $next + 1)
    end
    if test (count $words) -ge $next
        set suffix $words[$next..-1]
    end
    for reply in ("$helper" --_complete (math $current - 1) $before[2..-1] "$prefix" $suffix 2>/dev/null)
        switch "$reply"
            case files
                __fish_complete_path (commandline -ct | string collect)
            case 'name *'
                string replace 'name ' '' -- "$reply"
        end
    end
end

complete -c eb -f -a '(__editorbookmarks_complete)'
