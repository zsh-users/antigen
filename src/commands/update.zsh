antigen-update () {
  # Update your bundles, i.e., `git pull` in all the plugin repos.
  date >! $ADOTDIR/revert-info

  # Clear log
  :> $_ANTIGEN_LOG_PATH

  # If no argument is given we update all bundles
  if [[ $# -eq 0  ]]; then
    # Here we're ignoring all non cloned bundles (ie, --no-local-clone)
    -antigen-get-cloned-bundles | while read url; do
      -antigen-update-bundle $url
    done
  else
    local bundle=$1
    local record=$(-antigen-find-record $bundle)
    local url=$(echo $record | cut -d' ' -f1)
    local make_local_clone=$(echo $record | cut -d' ' -f4)

    if [[ $make_local_clone == "false" ]]; then
      echo "Bundle has no local clone. Can't update."
      return 1
    fi

    if [[ -n "$url" ]]; then
      -antigen-update-bundle $url
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

