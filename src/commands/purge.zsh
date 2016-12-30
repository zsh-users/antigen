# Remove a bundle from filesystem
#
# Usage
#   antigen-purge example/bundle [--force]
#
# Returns
#   Nothing. Removes bundle from filesystem.
antigen-purge () {
  local bundle=$1
  local force=$2

  # Put local keyword/variable definition on top
  # for zsh <= 5.0.0 otherwise will complain about it
  local record=""
  local url=""
  local make_local_clone=""

  if [[ $# -eq 0  ]]; then
    echo "Antigen: Missing argument."
    return 1
  fi

  # local keyword doesn't work on zsh <= 5.0.0
  record=$(-antigen-find-record $bundle)
  url="$(echo "$record" | cut -d' ' -f1)"
  make_local_clone=$(echo "$record" | cut -d' ' -f4)

  if [[ $make_local_clone == "false" ]]; then
    echo "Bundle has no local clone. Will not be removed."
    return 1
  fi

  if [[ -n "$url" ]]; then
    if -antigen-purge-bundle $url $force; then
      antigen-reset
    fi
  else
    echo "Bundle not found in record. Try 'antigen bundle $bundle' first."
    return 1
  fi

  return 0
}

# Remove a bundle from filesystem
#
# Usage
#   antigen-purge http://github.com/example/bundle [--force]
#
# Returns
#   Nothing. Removes bundle from filesystem.
-antigen-purge-bundle () {
  local url=$1
  local force=$2
  local clone_dir=""

  if [[ $# -eq 0  ]]; then
    echo "Antigen: Missing argument."
    return 1
  fi

  clone_dir=$(-antigen-get-clone-dir "$url")
  if [[ $force == "--force" ]]; then
    rm -rf "$clone_dir"
    return 0
  elif read -q "?Remove '$clone_dir'? (y/n) "; then
    echo ""
    rm -rf "$clone_dir"
    return 0
  else
    return 1
  fi
}
