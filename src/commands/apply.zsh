# Initialize completion
antigen-apply () {
  \rm -f $ANTIGEN_COMPDUMP

  # Auto determine check_files
  if [[ -z "$ANTIGEN_CHECK_FILES" ]]; then
    local src="${${funcfiletrace[2]%:*}##* }"
    ANTIGEN_CHECK_FILES+=($src)
  fi

  # Load the compinit module. This will readefine the `compdef` function to
  # the one that actually initializes completions.
  autoload -Uz compinit
  compinit -C -d "$ANTIGEN_COMPDUMP"
  if [[ ! -f "$ANTIGEN_COMPDUMP.zwc" ]]; then
    # Apply all `compinit`s that have been deferred.
    for cdef in "${__deferred_compdefs[@]}"; do
      compdef "$cdef"
    done

    zcompile "$ANTIGEN_COMPDUMP"
  fi

  unset __deferred_compdefs

  -zcache-generate-cache
}
