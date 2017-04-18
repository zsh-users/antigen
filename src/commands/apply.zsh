# Initialize completion
antigen-apply () {
  \rm -f $ANTIGEN_COMPDUMP

  # Auto determine check_files
  if (( ! -antigen-interactive-mode )); then
    # There always should be 2 steps from original source as the recommended way is to use
    # `antigen` wrapper not `antigen-apply` directly.
    if [[ $ANTIGEN_AUTO_CONFIG == true && -z "$ANTIGEN_CHECK_FILES" && $#funcfiletrace -ge 2 ]]; then
      ANTIGEN_CHECK_FILES+=("${${funcfiletrace[2]%:*}##* }")
    fi
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

  [[ $ANTIGEN_CACHE != false ]] && -zcache-generate-cache
}
