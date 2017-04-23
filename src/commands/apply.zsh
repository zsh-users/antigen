# Initialize completion
antigen-apply () {
  local bundle
  \rm -f $ANTIGEN_COMPDUMP

  # install bundles
  if ! -antigen-interactive-mode; then
    -install-bundles
  fi

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

  [[ $ANTIGEN_CACHE != false ]] && -zcache-generate-cache
}

-install-bundles () {
  for bundle in $_ANTIGEN_BUNDLE_RECORD; do
    bundle=(${(@s/ /)bundle})

    local url=$bundle[1]
    local loc=$bundle[2]
    local btype=$bundle[3]
    local make_local_clone=$bundle[4]

    if -antigen-bundle-install "$url" "$loc" "$btype" "$make_local_clone"; then
      return 1
    fi
  done
}
