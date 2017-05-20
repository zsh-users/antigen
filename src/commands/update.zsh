# Updates the bundles or a single bundle.
#
# Usage
#    antigen-update [example/bundle]
#
# Returns
#    Nothing. Performs a `git pull`.
antigen-update () {
  local bundle=$1

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

  if [[ $# -eq 0 ]]; then
    echo "Antigen: Missing argument."
    return 1
  fi

  record=$(-antigen-find-record $bundle)
  if [[ ! -n "$record" ]]; then
    echo "Bundle not found in record. Try 'antigen bundle $bundle' first."
    return 1
  fi

  url="$(echo "$record" | cut -d' ' -f1)"
  make_local_clone=$(echo "$record" | cut -d' ' -f4)

  if [[ $make_local_clone == "false" ]]; then
    echo "Bundle has no local clone. Will not be updated."
    return 1
  fi

  # update=true verbose=false
  if ! -antigen-ensure-repo "$url" true false; then
    return 1
  fi
}
