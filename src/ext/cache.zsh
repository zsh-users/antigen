typeset -ga _ZCACHE_BUNDLE_SOURCE _ZCACHE_CAPTURE_BUNDLE
typeset -g _ZCACHE_CAPTURE_PREFIX

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
-antigen-cache-generate () {
  local -aU _fpath _PATH _sources
  local record

  LOG "Gonna generate cache for $_ZCACHE_BUNDLE_SOURCE"
  for record in $_ZCACHE_BUNDLE_SOURCE; do
    record=${record:A}
    # LOG "Caching $record"
    if [[ -f $record ]]; then
      # Adding $'\n' as a suffix as j:\n: doesn't work inside a heredoc.
      _sources+=("source '${record}';"$'\n')
    elif [[ -d $record ]]; then
      _PATH+=("${record}")
      _fpath+=("${record}")
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
typeset -gaU fpath path
fpath+=(${_fpath[@]}) path+=(${_PATH[@]})
_antigen_compinit () {
  autoload -Uz compinit; compinit -d "$ANTIGEN_COMPDUMP"; compdef _antigen antigen
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
typeset -g _ANTIGEN_CACHE_LOADED; _ANTIGEN_CACHE_LOADED=true
typeset -g ANTIGEN_CACHE_VERSION; ANTIGEN_CACHE_VERSION='{{ANTIGEN_VERSION}}'

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
  if -antigen-interactive-mode; then
    return 1
  fi

  _ZCACHE_CAPTURE_PREFIX=${_ZCACHE_CAPTURE_PREFIX:-"--zcache-"}
  _ZCACHE_BUNDLE_SOURCE=(); _ZCACHE_CAPTURE_BUNDLE=()

  # Cache auto config files to check for changes (.zshrc, .antigenrc etc)
  -antigen-set-default ANTIGEN_AUTO_CONFIG true
  
  # Default cache path.
  -antigen-set-default ANTIGEN_CACHE $ADOTDIR/init.zsh
  -antigen-set-default ANTIGEN_RSRC $ADOTDIR/.resources
  
  return 0
}

-antigen-cache-execute () {
  # Main function. Deferred antigen-apply.
  antigen-apply-cached () {
    # TRACE "APPLYING CACHE" EXT
    # Auto determine check_files
    # There always should be 5 steps from original source as the correct way is to use
    # `antigen` wrapper not `antigen-apply` directly and it's called by an extension.
    if [[ $ANTIGEN_AUTO_CONFIG == true && -z "$ANTIGEN_CHECK_FILES" && $#funcfiletrace -ge 5 ]]; then
      ANTIGEN_CHECK_FILES+=("${${funcfiletrace[5]%:*}##* }")
    fi

    # Generate and compile cache
    -antigen-cache-generate
    [[ -f "$ANTIGEN_CACHE" ]] && source "$ANTIGEN_CACHE";
    
    unset _ZCACHE_BUNDLE_SOURCE _ZCACHE_CAPTURE_BUNDLE _ZCACHE_CAPTURE_FUNCTIONS

    # Release all hooked functions
    antigen-remove-hook -antigen-load-env-cached
    antigen-remove-hook -antigen-load-source-cached
    antigen-remove-hook antigen-bundle-cached
  }
  
  antigen-add-hook antigen-apply antigen-apply-cached post once
  
  # Defer antigen-bundle.
  antigen-bundle-cached () {
    _ZCACHE_CAPTURE_BUNDLE+=("${(j: :)${@}}")
  }
  antigen-add-hook antigen-bundle antigen-bundle-cached pre
  
  # Defer loading.
  -antigen-load-env-cached () {
    local bundle
    typeset -A bundle; bundle=($@)
    local location=${bundle[dir]}/${bundle[loc]}
    
    # Load to path if there is no sourceable
    if [[ ${bundle[loc]} == "/" ]]; then
      _ZCACHE_BUNDLE_SOURCE+=("${location}")
      return
    fi

    _ZCACHE_BUNDLE_SOURCE+=("${location}")
  }
  antigen-add-hook -antigen-load-env -antigen-load-env-cached replace
  
  # Defer sourcing.
  -antigen-load-source-cached () {
    _ZCACHE_BUNDLE_SOURCE+=($@)
  }
  antigen-add-hook -antigen-load-source -antigen-load-source-cached replace
  
  return 0
}

# Generate static-cache file at $ANTIGEN_CACHE using currently loaded
# bundles from $_ANTIGEN_BUNDLE_RECORD
#
# Usage
#   antigen-cache-gen
#
# Returns
#   Nothing
antigen-cache-gen () {
  -antigen-cache-generate
}
