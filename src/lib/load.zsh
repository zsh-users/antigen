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
  typeset -A bundle; bundle=($@)

  typeset -Ua list; list=()
  local location=${bundle[path]}/${bundle[loc]}
  
  list+=(${location}(N.) ${location}*.plugin.zsh(N[1]) ${location}init.zsh(N) ${location}*.zsh(N) ${location}*.sh(N))

  # Load to path if there is no sourceable
  if [[ ${bundle[loc]} == "/" && $#list == 0 ]]; then
    PATH="$PATH:${location:A}"
    fpath+=("${location:A}")
    return 0
  fi

  # If there is any sourceable try to load it
  if ! -antigen-load-source; then
    return 1
  fi

  # Load to PATH
  PATH="$PATH:${location:A}"
  fpath+=("${location:A}")

  return 0
}

-antigen-load-source () {
  source "${list[1]}" 2>/dev/null
}
