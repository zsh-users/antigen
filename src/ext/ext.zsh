typeset -Ag _ANTIGEN_HOOKS; _ANTIGEN_HOOKS=()
typeset -Ag _ANTIGEN_HOOKS_META; _ANTIGEN_HOOKS_META=()
typeset -g _ANTIGEN_HOOK_PREFIX="-antigen-hook-"
typeset -g _ANTIGEN_EXTENSIONS; _ANTIGEN_EXTENSIONS=()

# -antigen-add-hook antigen-apply antigen-apply-hook replace
#   - Replaces hooked function with hook, do not call hooked function
#   - Return -1 to stop calling further hooks
# -antigen-add-hook antigen-apply antigen-apply-hook pre (pre-call)
#   - By default it will call hooked function
# -antigen-add-hook antigen-pply antigen-apply-hook post (post-call)
#   - Calls antigen-apply and then calls hook function
# Usage:
#  -antigen-add-hook antigen-apply antigen-apply-hook ["replace"|"pre"|"post"] ["once"|"repeat"]
antigen-add-hook () {
  local target="$1" hook="$2" type="$3" mode="${4:-repeat}"
  
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

  _ANTIGEN_HOOKS_META[$hook]="target $target type $type mode $mode called 0"
  
  # Do shadow for this function if there is none already
  local hook_function="${_ANTIGEN_HOOK_PREFIX}$target"
  if (( ! $+functions[$hook_function] )); then
    # Preserve hooked function
    eval "function ${_ANTIGEN_HOOK_PREFIX}$(functions -- $target)"

    # Create hook, call hook-handler to further process hook functions
    eval "function $target () {
      noglob -antigen-hook-handler $target \$@
      return \$?
    }"
  fi
  
  return 0
}

# Private function to handle multiple hooks in a central point.
-antigen-hook-handler () {
  local target="$1" args hook called
  local hooks meta
  shift
  typeset -a args; args=(${@})

  typeset -a pre_hooks replace_hooks post_hooks;
  typeset -a hooks; hooks=(${(s|:|)_ANTIGEN_HOOKS[$target]})
  
  typeset -A meta;
  for hook in $hooks; do
    meta=(${(s: :)_ANTIGEN_HOOKS_META[$hook]})
    if [[ ${meta[mode]} == "once" && ${meta[called]} == 1 ]]; then
      WARN "Ignoring hook due to mode ${meta[mode]}: $hook"
      continue
    fi

    let called=${meta[called]}+1
    meta[called]=$called
    _ANTIGEN_HOOKS_META[$hook]="${(kv)meta}"
    WARN "Updated meta: "${(kv)meta}

    case "${meta[type]}" in
      "pre")
      pre_hooks+=($hook)
      ;;
      "replace")
      replace_hooks+=($hook)
      ;;
      "post")
      post_hooks+=($hook)
      ;;
    esac
  done

  WARN "Processing hooks: ${hooks}"

  for hook in $pre_hooks; do
    WARN "Pre hook:" $hook $args
    noglob $hook $args
    [[ $? == -1 ]] && WARN "$hook shortcircuited" && return $ret
  done

  # A replace hook will return inmediately
  local replace_hook=0 ret=0
  for hook in $replace_hooks; do
    replace_hook=1
    # Should not be needed if `antigen-remove-hook` removed unneeded hooks.
    if (( $+functions[$hook] )); then
      WARN "Replace hook:" $hook $args
      noglob $hook $args
      [[ $? == -1 ]] && WARN "$hook shortcircuited" && return $ret
    fi
  done
  
  if [[ $replace_hook == 0 ]]; then
    WARN "${_ANTIGEN_HOOK_PREFIX}$target $args"
    noglob ${_ANTIGEN_HOOK_PREFIX}$target $args
    ret=$?
  else
    WARN "Replaced hooked function."
  fi

  for hook in $post_hooks; do
    WARN "Post hook:" $hook $args
    noglob $hook $args
    [[ $? == -1 ]] && WARN "$hook shortcircuited" && return $ret
  done
  
  LOG "Return from hook ${target} with ${ret}"

  return $ret
}

# Usage:
#  -antigen-remove-hook antigen-apply-hook
antigen-remove-hook () {
  local hook="$1"
  typeset -A meta; meta=(${(s: :)_ANTIGEN_HOOKS_META[$hook]})
  local target="${meta[target]}"
  local -a hooks; hooks=(${(s|:|)_ANTIGEN_HOOKS[$target]})

  # Remove registered hook
  if [[ $#hooks > 0 ]]; then
    hooks[$hooks[(I)$hook]]=()
  fi
  _ANTIGEN_HOOKS[${target}]="${(j|:|)hooks}"
  
  if [[ $#hooks == 0 ]]; then
    # Destroy base hook
    eval "function $(functions -- ${_ANTIGEN_HOOK_PREFIX}$target | sed s/${_ANTIGEN_HOOK_PREFIX}//)"
    if (( $+functions[${_ANTIGEN_HOOK_PREFIX}$target] )); then
      unfunction -- "${_ANTIGEN_HOOK_PREFIX}$target"
    fi
  fi

  unfunction -- $hook 2> /dev/null
}

# Remove all defined hooks.
-antigen-reset-hooks () {
  local target

  for target in ${(k)_ANTIGEN_HOOKS}; do
    # Release all hooked functions
    eval "function $(functions -- ${_ANTIGEN_HOOK_PREFIX}$target | sed s/${_ANTIGEN_HOOK_PREFIX}//)"
    unfunction -- "${_ANTIGEN_HOOK_PREFIX}$target" 2> /dev/null
  done
  
  _ANTIGEN_HOOKS=()
  _ANTIGEN_HOOKS_META=()
  _ANTIGEN_EXTENSIONS=()
}

# Initializes an extension
# Usage:
#  antigen-ext ext-name
antigen-ext () {
  local ext=$1
  local func="-antigen-$ext-init"
  if (( $+functions[$func] && $_ANTIGEN_EXTENSIONS[(I)$ext] == 0 )); then
    eval $func
    local ret=$?
    WARN "$func return code was $ret"
    if (( $ret == 0 )); then 
      LOG "LOADED EXTENSION $ext" EXT
      -antigen-$ext-execute && _ANTIGEN_EXTENSIONS+=($ext)
    else
      WARN "IGNORING EXTENSION $func" EXT
      return 1
    fi
    
  else
    printf "Antigen: No extension defined or already loaded: %s\n" $func >&2
    return 1
  fi
}

# List installed extensions
# Usage:
#   antigen ext-list
antigen-ext-list () {
  echo $_ANTIGEN_EXTENSIONS
}

# Initializes built-in extensions
# Usage:
#   antigen-ext-init
antigen-ext-init () {
  # Initialize extensions. unless in interactive mode.
  local ext
  for ext in ${(s/ /)_ANTIGEN_BUILTIN_EXTENSIONS}; do
    # Check if extension is loaded before intializing it
    (( $+functions[-antigen-$ext-init] )) && antigen-ext $ext
  done
}
