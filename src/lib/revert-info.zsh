# Updates revert-info data with git hash.
#
# This does process only cloned bundles.
#
# Usage
#    -antigen-revert-info
#
# Returns
#    Nothing. Generates/updates $ADOTDIR/revert-info.
-antigen-revert-info() {
  local url
  # Update your bundles, i.e., `git pull` in all the plugin repos.
  date >! $ADOTDIR/revert-info

  -antigen-get-cloned-bundles | while read url; do
    local clone_dir="$(-antigen-get-clone-dir "$url")"
    if [[ -d "$clone_dir" ]]; then
      (echo -n "$clone_dir:"
        cd -q "$clone_dir"
        git rev-parse HEAD) >> $ADOTDIR/revert-info
    fi
  done
}
