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
  typeset -a unused_clones clones
  
  local url record clone
  for record in $(-antigen-get-cloned-bundles); do
    url=${record% /*}
    clones+=("$(-antigen-get-clone-dir $url)")
  done

  for clone in $_ANTIGEN_BUNDLES/*/*(/); do
    if [[ $clones[(I)$clone] == 0 ]]; then
      unused_clones+=($clone)
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
      \rm -r "$clone"

      # Removing empty parent directory
      local parent=${clone:A:h}
      if [[ -z "$(ls -A $parent)" ]]; then
        \rm -r "$parent"
      fi

      echo ' done.'
    done
  else
    echo
    echo "Nothing deleted."
  fi
}
