# Syntaxes
#   antigen-bundle <url> [<loc>=/]
# Keyword only arguments:
#   branch - The branch of the repo to use for this bundle.
antigen-bundle () {
  # Bundle spec arguments' default values.
  local url="$ANTIGEN_DEFAULT_REPO_URL"
  local loc=/
  local branch=
  local no_local_clone=false
  local btype=plugin

  if [[ -z "$1" ]]; then
    echo "Antigen: Must provide a bundle url or name."
    return 1
  fi

  eval "$(-antigen-parse-bundle "$@")"

  local branch="master"
  if [[ $url == *\|* ]]; then
    branch="$(-antigen-parse-branch ${url%|*} ${url#*|})"
  fi

  local record="${url/\|/\\|} $loc $btype $make_local_clone"
  if [[ $_ANTIGEN_WARN_DUPLICATES != false && ${_ANTIGEN_BUNDLE_RECORD[(I)$record]} != 0 ]]; then
    # TODO DRY-out duplicate from get-bundles
    local bundle_name=$(-antigen-bundle-short-name $url)
    if [[ $loc != '/' ]]; then
      bundle_name="$bundle_name ~ $loc"
    fi
    if [[ -n $branch ]]; then
      bundle_name="$bundle_name @ $branch"
    fi

    printf "Seems %s is already installed!\n"  $bundle_name
    return 1
  fi

  # Ensure a clone exists for this repo, if needed.
  # Get the clone's directory as per the given repo url and branch.
  local clone_dir=$(-antigen-get-clone-dir $url)
  # Clone if it doesn't already exist.
  local start=$(date +'%s')
  
  if [[ $make_local_clone == true ]]; then
    local no_clone_present=false
    if [[ ! -d "$clone_dir" ]]; then
      local no_clone_present=true
    fi
    
    if [[ $no_clone_present == true ]]; then
      printf "Installing %s... " $(-antigen-bundle-short-name "$url" "$branch")
    fi

    if ! -antigen-ensure-repo "$url"; then
      # Return immediately if there is an error cloning
      printf "Error! Activate logging and try again.\n";
      return 1
    fi

    if [[ $no_clone_present == true ]]; then
      local took=$(( $(date +'%s') - $start ))
      printf "Done. Took %ds.\n" $took
    fi
  fi

  # Load the plugin.
  if ! -antigen-load "$url" "$loc" "$make_local_clone" "$btype"; then
    echo "Antigen: Failed to load $btype."
    return 1
  fi

  # Add it to the record.
  _ANTIGEN_BUNDLE_RECORD+=($record)
}
