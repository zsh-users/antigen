# Updates the bundles or a single bundle.
#
# Usage
#    antigen-update [example/bundle]
#
# Returns
#    Nothing. Performs a `git pull`.
antigen-update () {
  local bundle=$1 url

  # Clear log
  :> $ANTIGEN_LOG

  # Update revert-info data
  -antigen-revert-info

  # If no argument is given we update all bundles
  if [[ $# -eq 0  ]]; then
    # Here we're ignoring all non cloned bundles (ie, --no-local-clone)
    -antigen-get-cloned-bundles | while read url; do
      -antigen-update-bundle $url
    done
    # TODO next minor version
    # antigen-reset
  else
    if -antigen-update-bundle $bundle; then
      # TODO next minor version
      # antigen-reset
    else
      return $?
    fi
  fi
}

# Updates a bundle performing a `git pull`.
#
# Usage
#    -antigen-update-bundle example/bundle
#
# Returns
#    Nothing. Performs a `git pull`.
-antigen-update-bundle () {
  local bundle="$1"
  local record=""
  local url=""
  local make_local_clone=""
  local start=$(date +'%s')
    
  if [[ $# -eq 0 ]]; then
    printf "Antigen: Missing argument.\n" >&2
    return 1
  fi

  record=$(-antigen-find-record $bundle)
  if [[ ! -n "$record" ]]; then
    printf "Bundle not found in record. Try 'antigen bundle %s' first.\n" $bundle >&2
    return 1
  fi

  url="$(echo "$record" | cut -d' ' -f1)"
  make_local_clone=$(echo "$record" | cut -d' ' -f4)
  
  local branch="master"
  if [[ $url == *\|* ]]; then
    branch="$(-antigen-parse-branch ${url%|*} ${url#*|})"
  fi

  printf "Updating %s... " $(-antigen-bundle-short-name "$url" "$branch")
  
  if [[ $make_local_clone == "false" ]]; then
    printf "Bundle has no local clone. Will not be updated.\n" >&2
    return 1
  fi

  # update=true verbose=false
  if ! -antigen-ensure-repo "$url" true false; then
    printf "Error! Activate logging and try again.\n" >&2
    return 1
  fi
  
  local took=$(( $(date +'%s') - $start ))
  printf "Done. Took %ds.\n" $took
}
