# Initialize completion
antigen-apply () {
  \rm -f $_ANTIGEN_COMPDUMP

  # Load the compinit module. This will readefine the `compdef` function to
  # the one that actually initializes completions.
  autoload -Uz compinit
  compinit -C -d "$_ANTIGEN_COMPDUMP"
  if [[ ! -f "$_ANTIGEN_COMPDUMP.zwc" ]]; then
    # Apply all `compinit`s that have been deferred.
    for cdef in "${__deferred_compdefs[@]}"; do
      compdef "$cdef"
    done

    zcompile "$_ANTIGEN_COMPDUMP"
  fi

  unset __deferred_compdefs

  if (( _zdotdir_set )); then
    ZDOTDIR=$_old_zdotdir
  else
    unset ZDOTDIR
    unset _old_zdotdir
  fi
  unset _zdotdir_set
  
  -zcache-generate-cache
}
