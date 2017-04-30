typeset -ga _ZCACHE_BUNDLE_SOURCE _ZCACHE_CAPTURE_BUNDLE _ZCACHE_CAPTURE_FUNCTIONS
typeset -g _ZCACHE_CAPTURE_PREFIX
_ZCACHE_CAPTURE_FUNCTIONS=(antigen-bundle -antigen-load-env -antigen-load-source antigen-apply)
_ZCACHE_CAPTURE_PREFIX=${_ZCACHE_CAPTURE_PREFIX:-"--zcache-"}

# Generates cache from listed bundles.
#
# Iterates over _ANTIGEN_BUNDLE_RECORD and join all needed sources into one,
# if this is done through -antigen-load-list.
# Result is stored in ANTIGEN_CACHE.
#
# _ANTIGEN_BUNDLE_RECORD and fpath is stored in cache.
#
# Usage
#   -zcache-generate-cache
#
# Returns
#   Nothing. Generates ANTIGEN_CACHE
-zcache-generate-cache () {
  local -aU _fpath _PATH _sources
  local record

  for record in $_ZCACHE_BUNDLE_SOURCE; do
    record=${record:A}
    if [[ -f $record ]]; then
      # Adding $'\n' as a suffix as j:\n: doesn't work inside a heredoc.
      _sources+=("source '${record}';"$'\n')
    elif [[ -d $record ]]; then
      _PATH+=("${record}")
      _fpath+=("${record}")

      # Support prezto function loading. See https://github.com/zsh-users/antigen/pull/428
      if [[ -d "${record}/functions" ]]; then
        _PATH+=("${record}/functions")
        _fpath+=("${record}/functions")
      fi

    fi
  done

cat > $ANTIGEN_CACHE <<EOC
#-- START ZCACHE GENERATED FILE
#-- GENERATED: $(date)
#-- ANTIGEN {{ANTIGEN_VERSION}}
$(functions -- _antigen)
antigen () {
  local MATCH MBEGIN MEND
  [[ "\$ZSH_EVAL_CONTEXT" =~ "toplevel:*" || "\$ZSH_EVAL_CONTEXT" =~ "cmdarg:*" ]] && source "$_ANTIGEN_INSTALL_DIR/antigen.zsh" && eval antigen \$@;
  return 0;
}
fpath+=(${_fpath[@]}); PATH="\$PATH:${(j/:/)_PATH}"
_antigen_compinit () {
  autoload -Uz compinit; compinit -C -d "$ANTIGEN_COMPDUMP"; compdef _antigen antigen
  add-zsh-hook -D precmd _antigen_compinit
}
autoload -Uz add-zsh-hook; add-zsh-hook precmd _antigen_compinit
compdef () {}

if [[ -n "$ZSH" ]]; then
  ZSH="$ZSH"; ZSH_CACHE_DIR="$ZSH_CACHE_DIR"
fi
#--- BUNDLES BEGIN
${(j::)_sources}
#--- BUNDLES END
typeset -gaU _ANTIGEN_BUNDLE_RECORD; _ANTIGEN_BUNDLE_RECORD=($(print ${(qq)_ANTIGEN_BUNDLE_RECORD}))
typeset -g _ANTIGEN_CACHE_LOADED=true ANTIGEN_CACHE_VERSION='{{ANTIGEN_VERSION}}'

#-- END ZCACHE GENERATED FILE
EOC

  { zcompile "$ANTIGEN_CACHE" } &!

  # Compile config files, if any
  [[ $ANTIGEN_AUTO_CONFIG == true && -n $ANTIGEN_CHECK_FILES ]] && {
    echo "$ANTIGEN_CHECK_FILES" >! "$ANTIGEN_RSRC"
    zcompile "$ANTIGEN_CHECK_FILES"
  } &!

  return true
}

# Capture functions
-zcache-capture () {
  local f; for f in $_ZCACHE_CAPTURE_FUNCTIONS; do
    eval "function ${_ZCACHE_CAPTURE_PREFIX}$(functions -- ${f})"
  done
}

# Release previously captured functions
-zcache-release-function () {
  local f=$1
  eval "function $(functions -- ${_ZCACHE_CAPTURE_PREFIX}${f} | sed s/${_ZCACHE_CAPTURE_PREFIX}//)"
  unfunction -- ${_ZCACHE_CAPTURE_PREFIX}${f} &> /dev/null
}

-zcache-release () {
  local f; for f in $_ZCACHE_CAPTURE_FUNCTIONS; do
    -zcache-release-function $f
  done
}

# Initializes caching mechanism.
#
# Hooks `antigen-bundle` and `antigen-apply` in order to defer bundle install
# and load. All bundles are loaded from generated cache rather than dynamically
# as these are bundled.
#
# Usage
#  -antigen-cache-init
# Returns
#  Nothing
-antigen-cache-init () {
  _ZCACHE_BUNDLE_SOURCE=()
  _ZCACHE_CAPTURE_BUNDLE=()
  
  # Release any previously hooked functions
  -zcache-release
  -zcache-capture
  antigen-apply () {
    # Release function to apply
    -zcache-release-function antigen-bundle

    # Auto determine check_files
    # There always should be 2 steps from original source as the correct way is to use
    # `antigen` wrapper not `antigen-apply` directly.
    if [[ $ANTIGEN_AUTO_CONFIG == true && -z "$ANTIGEN_CHECK_FILES" && $#funcfiletrace -ge 2 ]]; then
      ANTIGEN_CHECK_FILES+=("${${funcfiletrace[2]%:*}##* }")
    fi
 
    local bundle
    for bundle in "${_ZCACHE_CAPTURE_BUNDLE[@]}"; do
      antigen-bundle "${=bundle[@]}"
    done

    # Generate and compile cache
    -zcache-generate-cache
    
    # Release all hooked functions
    -zcache-release

    [[ -f "$ANTIGEN_CACHE" ]] && source "$ANTIGEN_CACHE";
    
    unset _ZCACHE_BUNDLE_SOURCE _ZCACHE_CAPTURE_BUNDLE _ZCACHE_CAPTURE_FUNCTIONS

    # Do apply compdump
    antigen-apply
  }
  
  antigen-bundle () {
    _ZCACHE_CAPTURE_BUNDLE+=("${(j: :)${@}}")
  }

  # Defer loading.
  -antigen-load-env () {
    typeset -A bundle; bundle=($@)
    local location=${bundle[path]}/${bundle[loc]}
    
    # Load to path if there is no sourceable
    if [[ ${bundle[loc]} == "/" ]]; then
      _ZCACHE_BUNDLE_SOURCE+=("${location}")
      return
    fi

    _ZCACHE_BUNDLE_SOURCE+=("${location}")
  }
  
  -antigen-load-source () {
    _ZCACHE_BUNDLE_SOURCE+=(${list})
  }
}
