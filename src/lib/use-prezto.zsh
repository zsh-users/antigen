-antigen-use-prezto () {
    _zdotdir_set=${+parameters[ZDOTDIR]}
    if (( _zdotdir_set )); then
        _old_zdotdir=$ZDOTDIR
    fi
    export ZDOTDIR=$ADOTDIR/repos/

    antigen-bundle sorin-ionescu/prezto
}
