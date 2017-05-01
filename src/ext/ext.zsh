typeset -Ag _ANTIGEN_HOOKS; _ANTIGEN_HOOKS=()
typeset -Ag _ANTIGEN_HOOKS_TARGET; _ANTIGEN_HOOKS_TARGET=()
typeset -Ag _ANTIGEN_HOOKS_TYPE; _ANTIGEN_HOOKS_TYPE=()
typeset -g _ANTIGEN_HOOK_PREFIX="::antigen-hook::"

# -antigen-add-hook antigen-apply antigen-apply-hook replace
#   - Replaces hooked function with hook, do not call it
# -antigen-add-hook antigen-apply antigen-apply-hook pre (pre-call)
#   - By default it will call hooked function
#   - Return -1 to stop from calling hooked function
# -antigen-add-hook antigen-pply antigen-apply-hook post (post-call)
#   - Calls antigen-apply and then calls hook function
#   - Return non-zero to overwrite return status
# Usage:
#  -antigen-add-hook antigen-apply antigen-apply-hook ["replace"|"pre"|"post"]
antigen-add-hook () {
  local target="$1" hook="$2" type="$3"
  
  if (( ! $+functions[$target] )); then
    printf "Antigen: Function %s doesn't exist.\n" $target
    return 1
  fi

  if (( ! $+functions[$hook] )); then
    printf "Antigen: Function %s doesn't exist.\n" $hook
    return 1
  fi

  if [[ "${_ANTIGEN_HOOKS[$target]}" == "" ]]; then
    _ANTIGEN_HOOKS[$target]="${hook}"
  else
    _ANTIGEN_HOOKS[$target]="${_ANTIGEN_HOOKS[$target]}:${hook}"
  fi

  _ANTIGEN_HOOKS_TARGET[$hook]="$target"
  _ANTIGEN_HOOKS_TYPE[$hook]="$type"
  
  # Do shadow for this function if there is none already
  local hook_function="${_ANTIGEN_HOOK_PREFIX}$target"
  if (( ! $+functions[$hook_function] )); then
    # Preserve hooked function
    eval "function ${_ANTIGEN_HOOK_PREFIX}$(functions -- $target)"

    # Create hook, call hook-handler to further process hook functions
    eval "function $target () {
      -antigen-hook-handler $target \${@//\*/\\\*}
      return \$?
    }"
  fi
  
  return 0
}

# Private function to handle multiple hooks in a central point.
-antigen-hook-handler () {
  local target="$1"
  shift
  local args=${@}

  typeset -a hooks; hooks=(${(s|:|)_ANTIGEN_HOOKS[$target]})

  local hook
  # A replace hook will return inmediately
  for hook in $hooks; do
    local called=0
    if [[ ${_ANTIGEN_HOOKS_TYPE[$hook]} == "replace" ]]; then
      eval $hook $args
      called=1
    fi
    if [[ $called == 1 ]]; then
      return
    fi
  done

  for hook in $hooks; do
    if [[ ${_ANTIGEN_HOOKS_TYPE[$hook]} == "pre" ]]; then
      eval $hook $args
    fi
  done

  eval "${_ANTIGEN_HOOK_PREFIX}$target" $args
  local res=$?

  for hook in $hooks; do
    if [[ ${_ANTIGEN_HOOKS_TYPE[$hook]} == "post" ]]; then
      eval $hook $args
    fi
  done
  
  return $res
}

# Usage:
#  -antigen-remove-hook antigen-apply-hook
antigen-remove-hook () {
  local hook="$1" target
  local -a hooks
  target=${_ANTIGEN_HOOKS_TARGET[$hook]}
  hooks=(${(s|:|)_ANTIGEN_HOOKS[$target]})

  # Remove registered hook
  hooks[$hooks[(I)$hook]]=()
  _ANTIGEN_HOOKS[$target]=${(j|:|)hooks}
  #_ANTIGEN_HOOKS_TARGET[$hook]=()
  
  if [[ $#hooks == 0 ]]; then
    # Destroy base hook
    eval "function $(functions -- ${_ANTIGEN_HOOK_PREFIX}$target | sed s/${_ANTIGEN_HOOK_PREFIX}//)"
    unfunction -- "${_ANTIGEN_HOOK_PREFIX}$target"
  fi

  unfunction -- $hook 2> /dev/null
}

# Remove all defined hooks.
-antigen-reset-hooks () {
  local target

  for target in ${(k)_ANTIGEN_HOOKS}; do
    # Release all hooked functions
    eval "function $(functions -- ${_ANTIGEN_HOOK_PREFIX}$target | sed s/${_ANTIGEN_HOOK_PREFIX}//)"
    unfunction -- "${_ANTIGEN_HOOK_PREFIX}$target"
  done
  
  _ANTIGEN_HOOKS=()
  _ANTIGEN_HOOKS_TYPE=()
}

# Initializes an extension
# Usage:
#  antigen-ext ext-name
antigen-ext () {
  local ext=$1
  local func="-antigen-$ext-init"
  if (( $+functions[$func] )); then
    eval $func
  else
    printf "Antigen: No extension defined: %s\n" $func >&2
    return 1
  fi
}
