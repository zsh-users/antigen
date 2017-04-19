# Reads $ADORDIR/revert-info and restores bundles' revision
antigen-revert () {
  local line
  if [[ -f $ADOTDIR/revert-info ]]; then
    cat $ADOTDIR/revert-info | sed -n '1!p' | while read line; do
      local dir="$(echo "$line" | cut -d: -f1)"
      git --git-dir="$dir/.git" --work-tree="$dir" \
        checkout "$(echo "$line" | cut -d: -f2)" 2> /dev/null
    done

    echo "Reverted to state before running -update on $(
            cat $ADOTDIR/revert-info | sed -n '1p')."

  else
    echo 'No revert information available. Cannot revert.' >&2
    return 1
  fi
}
