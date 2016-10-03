-antigen-load-list () {
  local url="$1"
  local loc="$2"
  local make_local_clone="$3"
  local sources=''

  # The full location where the plugin is located.
  local location
  if $make_local_clone; then
      location="$(-antigen-get-clone-dir "$url")/"
  else
      location="$url/"
  fi

  [[ $loc != "/" ]] && location="$location$loc"

  if [[ ! -f "$location" && ! -d "$location" ]]; then
      return 1
  fi

  if [[ -f "$location" ]]; then
      sources="$location"
  else

      # Source the plugin script.
      # FIXME: I don't know. Looks very very ugly. Needs a better
      # implementation once tests are ready.
      local script_loc="$(ls "$location" | grep '\.plugin\.zsh$' | head -n1)"

      if [[ -f $location/$script_loc ]]; then
          # If we have a `*.plugin.zsh`, source it.
          sources="$location/$script_loc"

      elif [[ -f $location/init.zsh ]]; then
          # Otherwise source it.
          sources="$location/init.zsh"

      elif ls "$location" | grep -l '\.zsh$' &> /dev/null; then
          # If there is no `*.plugin.zsh` file, source *all* the `*.zsh`
          # files.

          for script ($location/*.zsh(N)) {
            sources="$sources\n$script"
          }

      elif ls "$location" | grep -l '\.sh$' &> /dev/null; then
          # If there are no `*.zsh` files either, we look for and source any
          # `*.sh` files instead.
          for script ($location/*.sh(N)) {
            sources="$sources\n$script"
          }
      fi
  fi

  echo "$sources"
}
