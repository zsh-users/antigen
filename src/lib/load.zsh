-antigen-load () {
  local url="$1"
  local loc="$2"
  local make_local_clone="$3"
  local src

  for src in $(-antigen-load-list "$url" "$loc" "$make_local_clone"); do
      if [[ -d "$src" ]]; then
          if (( ! ${fpath[(I)$location]} )); then
              fpath=($location $fpath)
          fi
      else
          source "$src"
      fi
  done

  local location
  if $make_local_clone; then
      location="$(-antigen-get-clone-dir "$url")/$loc"
  else
      location="$url/"
  fi
  # Add to $fpath, for completion(s), if not in there already
  if (( ! ${fpath[(I)$location]} )); then
     fpath=($location $fpath)
  fi
}
