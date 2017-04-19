antigen-restore () {
  local line
  if [[ $# == 0 ]]; then
    echo 'Please provide a snapshot file to restore from.' >&2
    return 1
  fi

  local snapshot_file="$1"

  # TODO: Before doing anything with the snapshot file, verify its checksum.
  # If it fails, notify this to the user and confirm if restore should
  # proceed.

  echo -n "Restoring from $snapshot_file..."

  sed -n '1!p' "$snapshot_file" |
    while read line; do
      local version_hash="${line%% *}"
      local url="${line##* }"
      local clone_dir="$(-antigen-get-clone-dir "$url")"

      if [[ ! -d $clone_dir ]]; then
          git clone "$url" "$clone_dir" &> /dev/null
      fi

      (cd -q "$clone_dir" && git checkout $version_hash) &> /dev/null
    done

  echo ' done.'
  echo 'Please open a new shell to get the restored changes.'
}
