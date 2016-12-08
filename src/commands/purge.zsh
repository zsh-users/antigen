# Remove a bundle from filesystem
#
# Usage
#   antigen-purge example/bundle
#
# Returns
#   Nothing. Removes bundle from filesystem.
antigen-purge () {
  local bundle=$1
  local record=$(-antigen-find-record $bundle)
  local url=$(echo $record | cut -d' ' -f1)
  local make_local_clone=$(echo $record | cut -d' ' -f4)

  if [[ $make_local_clone == "false" ]]; then
    echo "Bundle has no local clone. Will not be removed."
    return 1
  fi
  
  if [[ -n "$url" ]]; then
    if -antigen-purge-bundle $url; then
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
#   antigen-purge http://github.com/example/bundle
#
# Returns
#   Nothing. Removes bundle from filesystem.
-antigen-purge-bundle () {
  local url=$1
  local clone_dir="$(-antigen-get-clone-dir $url)"
  if read -q "?Remove '$clone_dir'? (y/n) "; then
    echo ""
    rm -rf "$clone_dir"
  else
    return 1
  fi

  return 0
}
