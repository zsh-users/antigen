-antigen-load () {
  local url="$1"
  local loc="$2"
  local make_local_clone="$3"
  local btype="$4"
  local src

  for src in $(-antigen-load-list "$url" "$loc" "$make_local_clone"); do
      if [[ -d "$src" ]]; then
          if (( ! ${fpath[(I)$location]} )); then
              fpath=($location $fpath)
          fi
      else
          # Hack away local variables. See https://github.com/zsh-users/antigen/issues/122
          # This is needed to seek-and-destroy local variable definitions *outside*
          # function-contexts. This is done in this particular way *only* for
          # interactive bundle/theme loading, for static loading -99.9% of the time-
          # eval and subshells are not needed.
          if [[ "$btype" == "theme" ]]; then
              eval "$(cat $src | sed -Ee '/\{$/,/^\}/!{
                      s/^local //
                  }')"
          else
              source "$src"
          fi
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
