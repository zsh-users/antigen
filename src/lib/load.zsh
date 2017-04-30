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

  # Prioritize location when given.
  if [[ -f ${location} ]]; then
    list=(${location})
  else
    # Directory locations must be suffixed with slash
    location="$location/"

    # Prioritize theme with antigen-theme
    if [[ ${bundle[btype]} == "theme" ]]; then
      list=(${location}*.zsh-theme(N[1]))
    fi

    # Common frameworks
    if [[ $#list == 0 ]]; then
      list=(${location}*.plugin.zsh(N[1]) ${location}init.zsh(N[1]))
    fi

    # Default to zsh and sh
    if [[ $#list == 0 ]]; then
      list=(${location}*.zsh(N) ${location}*.sh(N))
    fi
  fi

  -antigen-load-env ${(kv)bundle}

  # If there is any sourceable try to load it
  if ! -antigen-load-source && [[ ! -d ${location} ]]; then
    return 1
  fi

  return 0
}

-antigen-load-env () {
  typeset -A bundle; bundle=($@)
  local location=${bundle[path]}/${bundle[loc]}
  
  # Support prezto function loading. See https://github.com/zsh-users/antigen/pull/428
  if [[ -d "${location}/functions" ]]; then
    PATH="$PATH:${location:A}/functions"
    fpath+=("${location:A}/functions")
  fi
  
  # Load to path if there is no sourceable
  if [[ -d ${location} ]]; then
    PATH="$PATH:${location:A}"
    fpath+=("${location:A}")
    return
  fi

  PATH="$PATH:${location:A:h}"
  fpath+=("${location:A:h}")
}

-antigen-load-source () {
  source "${list[@]}" 2>/dev/null
}
