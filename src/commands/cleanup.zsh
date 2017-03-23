# Cleanup unused repositories.
antigen-cleanup () {
  local force=false
  if [[ $1 == --force ]]; then
    force=true
  fi

  if [[ ! -d "$_ANTIGEN_BUNDLES" || -z "$(\ls "$_ANTIGEN_BUNDLES")" ]]; then
    echo "You don't have any bundles."
    return 0
  fi

  # Find directores in _ANTIGEN_BUNDLES, that are not in the bundles record.
  typeset -a unused_clones clones;
  
  for bundle in $_ANTIGEN_BUNDLE_RECORD; do
    clones+=($(-antigen-get-clone-dir ${=bundle% *}))
  done

  for bundle in $_ANTIGEN_BUNDLES/*/*(/); do    
    if [[ $clones[(I)$bundle] == 0 ]]; then
      unused_clones+=($bundle)
    fi
  done

  if [[ -z $unused_clones ]]; then
    echo "You don't have any unidentified bundles."
    return 0
  fi

  echo 'You have clones for the following repos, but are not used.'
  echo "\n${(j:\n:)unused_clones}"

  if $force || (echo -n '\nDelete them all? [y/N] '; read -q); then
    echo
    echo
    for clone in $unused_clones; do
      echo -n "Deleting clone \"$clone\"..."
      \rm -rf "$clone"
      echo ' done.'
    done
  else
    echo
    echo "Nothing deleted."
  fi
  
  # Remove empty clones
  local empty_repos=($_ANTIGEN_BUNDLES/**/*(/^F))
  if [[ -n $empty_repos ]]; then
    \rm -d $empty_repos
  fi
}
