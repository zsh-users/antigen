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

  if [[ $# -eq 0  ]]; then
    echo "Antigen: Missing argument." >&2
    return 1
  fi

  if -antigen-purge-bundle $bundle $force; then
    antigen-reset
  else
    return $?
  fi

  return 0
}

# Remove a bundle from filesystem
#
# Usage
#   antigen-purge example/bundle [--force]
#
# Returns
#   Nothing. Removes bundle from filesystem.
-antigen-purge-bundle () {
  local bundle=$1
  local force=$2
  local clone_dir=""

  local record=""
  local url=""
  local make_local_clone=""

  if [[ $# -eq 0  ]]; then
    echo "Antigen: Missing argument." >&2
    return 1
  fi

  # local keyword doesn't work on zsh <= 5.0.0
  record=$(-antigen-find-record $bundle)

  if [[ ! -n "$record" ]]; then
    echo "Bundle not found in record. Try 'antigen bundle $bundle' first." >&2
    return 1
  fi

  url="$(echo "$record" | cut -d' ' -f1)"
  make_local_clone=$(echo "$record" | cut -d' ' -f4)

  if [[ $make_local_clone == "false" ]]; then
    echo "Bundle has no local clone. Will not be removed." >&2
    return 1
  fi

  clone_dir=$(-antigen-get-clone-dir "$url")
  if [[ $force == "--force" ]] || read -q "?Remove '$clone_dir'? (y/n) "; then
    # Need empty line after read -q
    [[ ! -n $force ]] && echo "" || echo "Removing '$clone_dir'.";
    rm -rf "$clone_dir"
    return $?
  fi

  return 1
}
