antigen-theme () {
    # This is only needed on interactive mode
    autoload -U add-zsh-hook
    local hook
    for hook in chpwd precmd preexec periodic zshaddhistory; do
        add-zsh-hook -D "${hook}" "prompt_*"
        add-zsh-hook -D "${hook}" "*_${hook}" # common in omz themes 
        add-zsh-hook -d "${hook}" "vcs_info"  # common in omz themes
    done

    if [[ "$1" != */* && "$1" != --* ]]; then
        # The first argument is just a name of the plugin, to be picked up from
        # the default repo.
        local name="${1:-robbyrussell}"
        antigen-bundle --loc=themes/$name --btype=theme

    else
        antigen-bundle "$@" --btype=theme

    fi
}
