# Initialize completion
antigen-apply () {
    # We need to check for interactivity because if cache is configured
    # antigen-apply is called by zcache-done, which calls -antigen-reset-compdump
    # as well, so here we avoid to run -antigen-reset-compdump twice.
    #
    # We do not want to always call -antigen-reset-compdump, but only when
    # - cache is reset
    # - user issues antigen-apply command
    # Here we are taking care of antigen-apply command. See zcache-done function
    # for the former case.
    -antigen-interactive-mode
    if [[ $_ANTIGEN_INTERACTIVE == true ]]; then
        # Force zcompdump reset
        -antigen-reset-compdump
    fi

    # Load the compinit module. This will readefine the `compdef` function to
    # the one that actually initializes completions.
    autoload -U compinit
    compinit -i -d $ANTIGEN_COMPDUMPFILE

    # Apply all `compinit`s that have been deferred.
    local cdef
    for cdef in "${__deferred_compdefs[@]}"; do
        compdef "$cdef"
    done

    unset __deferred_compdefs

    if (( _zdotdir_set )); then
        ZDOTDIR=$_old_zdotdir
    else
        unset ZDOTDIR
        unset _old_zdotdir
    fi
    unset _zdotdir_set
}
