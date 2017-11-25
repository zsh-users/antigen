# Syntaxes
#   antigen-bundle <url> [<loc>=/]
# Keyword only arguments:
#   branch - The branch of the repo to use for this bundle.
antigen-bundle () {
  TRACE "Called antigen-bundle with $@" BUNDLE
  if [[ -z "$1" ]]; then
    printf "Antigen: Must provide a bundle url or name.\n" >&2
    return 1
  fi

  builtin typeset -A bundle; -antigen-parse-args 'bundle' ${=@}
  if [[ -z ${bundle[btype]} ]]; then
    bundle[btype]=bundle
  fi

  local record="${bundle[url]} ${bundle[loc]} ${bundle[btype]} ${bundle[make_local_clone]}"
  if [[ $_ANTIGEN_WARN_DUPLICATES == true && ! ${_ANTIGEN_BUNDLE_RECORD[(I)$record]} == 0 ]]; then
    printf "Seems %s is already installed!\n" ${bundle[name]}
    return 1
  fi
 
  # Clone bundle if we haven't done do already.
  if [[ ! -d "${bundle[dir]}" ]]; then
    if ! -antigen-bundle-install ${(kv)bundle}; then
      return 1
    fi
  fi

  # Load the plugin.
  if ! -antigen-load ${(kv)bundle}; then
    TRACE "-antigen-load failed to load ${bundle[name]}" BUNDLE
    printf "Antigen: Failed to load %s.\n" ${bundle[btype]} >&2
    return 1
  fi
  
  # Only add it to the record if it could be installed and loaded.
  _ANTIGEN_BUNDLE_RECORD+=("$record")
}

#
# Usage:
#   -antigen-bundle-install <record>
# Returns:
#   1 if it fails to install bundle
-antigen-bundle-install () {
  typeset -A bundle; bundle=($@)

  # Ensure a clone exists for this repo, if needed.
  # Get the clone's directory as per the given repo url and branch.
  local bpath="${bundle[dir]}"
  # Clone if it doesn't already exist.
  local start=$(date +'%s')

  printf "Installing %s... " "${bundle[name]}"

  if ! -antigen-ensure-repo "${bundle[url]}"; then
    # Return immediately if there is an error cloning
    TRACE "-antigen-bundle-instal failed to clone ${bundle[url]}" BUNDLE
    printf "Error! Activate logging and try again.\n" >&2
    return 1
  fi

  local took=$(( $(date +'%s') - $start ))
  printf "Done. Took %ds.\n" $took
}
