-antigen-env-setup () {

    # Helper function: Same as `export $1=$2`, but will only happen if the name
    # specified by `$1` is not already set.
    -set-default () {
        local arg_name="$1"
        local arg_value="$2"
        eval "test -z \"\$$arg_name\" && export $arg_name='$arg_value'"
    }

    # Pre-startup initializations.
    -set-default ANTIGEN_DEFAULT_REPO_URL \
        https://github.com/robbyrussell/oh-my-zsh.git
    -set-default ADOTDIR $HOME/.antigen
    if [[ ! -d $ADOTDIR ]]; then
        mkdir -p $ADOTDIR
    fi
    -set-default _ANTIGEN_LOG_PATH "$ADOTDIR/antigen.log"
    -set-default ANTIGEN_COMPDUMPFILE "${ZDOTDIR:-$HOME}/.zcompdump"

    # Setup antigen's own completion.
    autoload -Uz compinit
    if $_ANTIGEN_COMP_ENABLED; then
        compinit -C
        compdef _antigen antigen
    fi

    # Remove private functions.
    unfunction -- -set-default

}
