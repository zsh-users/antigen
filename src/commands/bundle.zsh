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
    if [[ ${bundle[loc]} == "/" ]]; then
      printf "Antigen: Seems %s %s is already installed!\n" ${bundle[btype]} ${bundle[name]}
    else
      local local_name=${bundle[loc]#plugins/}
      printf "Antigen: Seems %s %s from %s is already installed!\n" ${bundle[btype]} ${local_name} ${bundle[name]}
    fi
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
    if [[ ${bundle[loc]} == "/" ]]; then
      printf "Antigen: Failed to load %s %s.\n" ${bundle[btype]} ${bundle[name]}
    else
      local local_name=${bundle[loc]#plugins/}
      printf "Antigen: Failed to load %s %s from %s.\n" ${bundle[btype]} ${local_name} ${bundle[name]}
    fi
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
    TRACE "-antigen-bundle-install failed to clone ${bundle[url]}" BUNDLE
    printf "Antigen: Error! Activate logging and try again.\n" >&2
    return 1
  fi

  local took=$(( $(date +'%s') - $start ))
  printf "Antigen: Done. Took %ds.\n" $took
}
