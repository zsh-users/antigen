antigen-apply () {

    # Initialize completion.
    local cdef

    # Load the compinit module. This will readefine the `compdef` function to
    # the one that actually initializes completions.
    autoload -U compinit
    if [[ -z $ANTIGEN_COMPDUMPFILE ]]; then
        compinit -i
    else
        compinit -i -d $ANTIGEN_COMPDUMPFILE
    fi

    # Apply all `compinit`s that have been deferred.
    eval "$(for cdef in $__deferred_compdefs; do
                echo compdef $cdef
            done)"

    unset __deferred_compdefs

    if (( _zdotdir_set )); then
        ZDOTDIR=$_old_zdotdir
    else
        unset ZDOTDIR
        unset _old_zdotdir
    fi;
    unset _zdotdir_set
}
