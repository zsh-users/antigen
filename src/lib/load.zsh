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

  # should be configurable, ie: form theme context should only look for .zsh-theme,
  # or loc, for bundle context should only look for .plugin.zsh or loc, if given
  # a loc it should fail when no $loc/$loc.plugin.zsh/$loc.zsh-theme/$loc.zs etc
  # do no exist
  typeset -a strategies=(location init) # dot-plugin zsh-theme zsh sh)
  typeset -a list;
  -antigen-load-list $strategies

  for line in $list; do
    source "$line"
    return 0
  done
  
  return 1
}

-antigen-load-list () {
  for strategy in $strategies; do
    -antigen-load-strategy-$strategy ${(kv)bundle}
    if [[ ! "${#list}" == 0 ]]; then
      break;
    fi
  done
}

-antigen-load-strategy-location () {
  typeset -A bundle; bundle=($@)
  if [[ ${bundle[loc]} == '/' ]]; then
    return
  fi

  local files=("${bundle[path]}/${bundle[loc]}.plugin.zsh"
    "${bundle[path]}/${bundle[loc]}.zsh-theme"
    "${bundle[path]}/${bundle[loc]}.zsh"
    "${bundle[path]}/${bundle[loc]}"
  )

  local file
  for file in $files; do
    if [[ -f $file ]]; then
      list+=$file
      break;
    fi
  done
}

-antigen-load-strategy-dot-plugin () {
  typeset -A bundle; bundle=($@)
  list+=(${bundle[path]}/*.plugin.zsh(N[1]))
}

-antigen-load-strategy-init () {
  typeset -A bundle; bundle=($@)
  local file="${bundle[path]}/init.zsh"
  if [[ -f $file ]]; then
    list+=$file
  fi
}

-antigen-load-strategy-zsh-theme () {
  typeset -A bundle; bundle=($@)
  list+=(${bundle[path]}/*.zsh-theme(N[1]))
}

-antigen-load-strategy-zsh () {
  typeset -A bundle; bundle=($@)
  list+=(${bundle[path]}/*.zsh(N))
}

-antigen-load-strategy-sh () {
  typeset -A bundle; bundle=($@)
  list+=(${bundle[path]}/*.sh(N))
}
