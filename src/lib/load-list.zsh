-antigen-load-list () {
  typeset -A bundle; bundle=($@)
  local var=$1
  shift;

  # The full location where the plugin is located.
  local location="${bundle[url]}"
  if [[ ${bundle[make_local_clone]} == true ]]; then
    location="${bundle[path]}"
  fi

  if [[ ${bundle[loc]} != "/" ]]; then
    location="$location/${bundle[loc]}"
  fi

  if [[ ! -f "$location" && ! -d "$location" ]]; then
    return 1
  fi

  if [[ -f "$location" ]]; then
    list+="$location"
    return
  fi

  # Load `*.zsh-theme` for themes
  if [[ "${bundle[btype]}" == "theme" ]]; then
    local theme_plugin
    theme_plugin=($location/*.zsh-theme(N[1]))
    if [[ -f "$theme_plugin" ]]; then
      list+="$theme_plugin"
      return
    fi
  fi

  # If we have a `*.plugin.zsh`, source it.
  local script_plugin
  script_plugin=($location/*.plugin.zsh(N[1]))
  if [[ -f "$script_plugin" ]]; then
    list+="$script_plugin"
    return
  fi

  # Otherwise source init.
  if [[ -f $location/init.zsh ]]; then
    list+="$location/init.zsh"
    return
  fi

  # If there is no `*.plugin.zsh` file, source *all* the `*.zsh` files.
  list+=($location/*.zsh(N) $location/*.sh(N))
  
  # Add to PATH (binary bundle)
  list+="$location"
  
  return 0
}
