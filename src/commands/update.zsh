# Updates the bundles or a single bundle.
#
# Usage
#    antigen-update [example/bundle]
#
# Returns
#    Nothing. Performs a `git pull`.
antigen-update () {
  # Clear log
  :> $_ANTIGEN_LOG_PATH

  # Update revert-info data
  -antigen-revert-info

  # If no argument is given we update all bundles
  if [[ $# -eq 0  ]]; then
    # Here we're ignoring all non cloned bundles (ie, --no-local-clone)
    -antigen-get-cloned-bundles | while read url; do
      -antigen-update-bundle $url
    done
  else
    local bundle=$1
    local records=($(echo $_ANTIGEN_BUNDLE_RECORD))
    local record=${records[(r)*$bundle*]}

    if [[ -n "$record" ]]; then
      -antigen-update-bundle ${=record}
    else
      echo "Bundle not found in record. Try 'antigen bundle $bundle' first."
      return 1
    fi
  fi
}

# Updates a bundle performing a `git pull`.
#
# Usage
#    -antigen-update-bundle https://github.com/example/bundle.git[|branch]
#
# Returns
#    Nothing. Performs a `git pull`.
-antigen-update-bundle () {
  local url="$1"

  if [[ ! -n "$url" ]]; then
    echo "Antigen: Missing argument."
    return 1
  fi

  # update=true verbose=false
  if ! -antigen-ensure-repo "$url" true false; then
    return 1
  fi
}

