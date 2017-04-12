# Load a given bundle by sourcing it.
#
# The function also modifies fpath to add the bundle path.
#
# Usage
#   -antigen-load "bundle-url" ["location"] ["make_local_clone"] ["btype"]
#
# Returns
#   Integer. 0 if success 1 if an error ocurred.
-antigen-load () {
  local url="$1"
  local loc="$2"
  local make_local_clone="$3"
  local btype="$4"
  local src

  local location="$url"
  if $make_local_clone; then
    location="$(-antigen-get-clone-dir "$url")"
  fi

  if [[ $loc != "/" ]]; then
    location="$location/$loc"
  fi

  if [[ -d "$location" ]]; then
    fpath+=($location)
  fi

  if [[ -d "$location/functions" ]]; then
    fpath+=($location/functions)
  fi

  local success=1
  -antigen-load-list "$url" "$loc" "$make_local_clone" "$btype" | while read line; do
    if [[ -f "$line" || -d "$line" ]]; then
      success=0
    fi

    if [[ -f "$line" ]]; then
      # Hack away local variables. See https://github.com/zsh-users/antigen/issues/122
      # This is needed to seek-and-destroy local variable definitions *outside*
      # function-contexts. This is done in this particular way *only* for
      # interactive bundle/theme loading, for static loading -99.9% of the time-
      # eval and subshells are not needed.
      if [[ "$btype" == "theme" ]]; then
        pushd "${line:A:h}" > /dev/null
        eval "$(cat $line | sed -Ee '/\{$/,/^\}/!{
               s/^local //
           }');"
        popd > /dev/null
      else
        source "$line"
      fi
    elif [[ -d "$line" ]]; then
      PATH="$PATH:$line"
    fi
  done

  return $success
}
