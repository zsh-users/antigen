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
  local -aU _fpath _PATH

  -antigen-load-list "$url" "$loc" "$make_local_clone" "$btype" | while read line; do
    if [[ -f "$line" ]]; then
      # Hack away local variables. See https://github.com/zsh-users/antigen/issues/122
      # This is needed to seek-and-destroy local variable definitions *outside*
      # function-contexts. This is done in this particular way *only* for
      # interactive bundle/theme loading, for static loading -99.9% of the time-
      # eval and subshells are not needed.
      if [[ "$btype" == "theme" ]]; then
        eval "__PREVDIR=$PWD; cd ${line:A:h};
              $(cat $line | sed -Ee '/\{$/,/^\}/!{
               s/^local //
           }'); cd $__PREVDIR"
      else
        source "$line"
      fi
    elif [[ -d "$line" ]]; then
      _PATH="$_PATH:$line"
    fi
  done

  local location="$url"
  if $make_local_clone; then
    location="$(-antigen-get-clone-dir "$url")"
  fi

  if [[ $loc != "/" ]]; then
    location="$location/$loc"
  fi

  if [[ -d "$location" ]]; then
    _fpath+=($location)
  fi

  if [[ -d "$location/functions" ]]; then
    _fpath+=($location/functions)
  fi

  local success=1
  if [[ -f "$location" || -d "$location" ]]; then
    PATH="$PATH:$_PATH"
    if (( ! ${fpath[(I)$location]} )); then
      fpath+=($_fpath)
    fi

    success=0
  fi

  return $success
}
