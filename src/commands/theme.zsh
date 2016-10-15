antigen-theme () {
    if [[ $_ANTIGEN_RESET_THEME_HOOKS == true ]]; then
        -antigen-theme-reset-hooks
    fi

    if [[ "$1" != */* && "$1" != --* ]]; then
        # The first argument is just a name of the plugin, to be picked up from
        # the default repo.
        local name="${1:-robbyrussell}"
        antigen-bundle --loc=themes/$name --btype=theme

    else
        antigen-bundle "$@" --btype=theme

    fi
}

-antigen-theme-reset-hooks () {
    # This is only needed on interactive mode
    autoload -U add-zsh-hook is-at-least
    local hook
    for hook in chpwd precmd preexec periodic; do
        # add-zsh-hook's -D option was introduced first in 4.3.6-dev and
        # 4.3.7 first stable, 4.3.5 and below may experiment minor issues
        # while switching themes interactively.
        if is-at-least 4.3.7; then
            add-zsh-hook -D "${hook}" "prompt_*"
            add-zsh-hook -D "${hook}" "*_${hook}" # common in omz themes 
        fi
        add-zsh-hook -d "${hook}" "vcs_info"  # common in omz themes
    done
}
