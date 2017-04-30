# Initialize completion
antigen-apply () {
  \rm -f "$ANTIGEN_COMPDUMP"

  # Load the compinit module. This will readefine the `compdef` function to
  # the one that actually initializes completions.
  autoload -Uz compinit
  compinit -C -d "$ANTIGEN_COMPDUMP"
  if [[ ! -f "$ANTIGEN_COMPDUMP.zwc" || "$ANTIGEN_COMPDUMP" -nt "$ANTIGEN_COMPDUMP.zwc" ]]; then
    # Apply all `compinit`s that have been deferred.
    local cdef
    for cdef in "${__deferred_compdefs[@]}"; do
      compdef "$cdef"
    done

    { zcompile "$ANTIGEN_COMPDUMP" } &!
  fi

  unset __deferred_compdefs
}
