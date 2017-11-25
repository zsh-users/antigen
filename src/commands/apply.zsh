# Initialize completion
antigen-apply () {
  LOG "Called antigen-apply"

  # Load the compinit module. This will readefine the `compdef` function to
  # the one that actually initializes completions.
  TRACE "Gonna create compdump file @ apply" COMPDUMP
  autoload -Uz compinit
  compinit -d "$ANTIGEN_COMPDUMP"

  # Apply all `compinit`s that have been deferred.
  local cdef
  for cdef in "${__deferred_compdefs[@]}"; do
    compdef "$cdef"
  done

  { zcompile "$ANTIGEN_COMPDUMP" } &!

  unset __deferred_compdefs
}
