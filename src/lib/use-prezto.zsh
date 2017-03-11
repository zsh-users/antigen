-antigen-use-prezto () {
  _zdotdir_set=${+parameters[ZDOTDIR]}
  if (( _zdotdir_set )); then
    _old_zdotdir=$ZDOTDIR
  fi
  ZDOTDIR=$ADOTDIR/repos/

  antigen-bundle $ANTIGEN_PREZTO_REPO_URL
}

