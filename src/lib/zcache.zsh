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
  local -aU _fpath _PATH
  local _payload _sources record

  for record in $_ZCACHE_BUNDLE_SOURCE; do
    record=${record:A}
    if [[ -f $record ]]; then
      _sources+="source \"${record}\";\NL"
    elif [[ -d $record ]]; then
      _PATH+=("${record}")
      _fpath+=("${record}")
    fi
  done

  _payload="#-- START ZCACHE GENERATED FILE
#-- GENERATED: $(date)
#-- ANTIGEN {{ANTIGEN_VERSION}}
$(functions -- _antigen)
antigen () {
  local MATCH MBEGIN MEND
  [[ \"\$ZSH_EVAL_CONTEXT\" =~ \"toplevel:*\" || \"\$ZSH_EVAL_CONTEXT\" =~ \"cmdarg:*\" ]] && source \""$_ANTIGEN_INSTALL_DIR/antigen.zsh"\" && eval antigen \$@;
  return 0;
}
fpath+=(${_fpath[@]}); PATH=\"\$PATH:${(j/:/)_PATH}\"
_antigen_compinit () {
  autoload -Uz compinit; compinit -C -d \"$ANTIGEN_COMPDUMP\"; compdef _antigen antigen
  add-zsh-hook -D precmd _antigen_compinit
}
autoload -Uz add-zsh-hook; add-zsh-hook precmd _antigen_compinit
compdef () {}\NL"

  # Cache omz/prezto env variables. See https://github.com/zsh-users/antigen/pull/387
  if [[ -n "$ZSH" ]]; then
    _payload+="ZSH=\"$ZSH\" ZSH_CACHE_DIR=\"$ZSH_CACHE_DIR\"\NL";
  fi

  _payload+=$_sources

  _payload+="typeset -gaU _ANTIGEN_BUNDLE_RECORD; _ANTIGEN_BUNDLE_RECORD=("$(print ${(qq)_ANTIGEN_BUNDLE_RECORD})")\NL"
  _payload+="typeset -g _ANTIGEN_CACHE_LOADED=true ANTIGEN_CACHE_VERSION='{{ANTIGEN_VERSION}}'\NL"

  _payload+="#-- END ZCACHE GENERATED FILE\NL"

  echo -E $_payload | sed 's/\\NL/\'$'\n/g' >! "$ANTIGEN_CACHE"

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
typeset -ga _ZCACHE_BUNDLE_SOURCE; _ZCACHE_BUNDLE_SOURCE=()
typeset -ga _ZCACHE_CAPTURE_BUNDLE; _ZCACHE_CAPTURE_BUNDLE=()
typeset -a _ZCACHE_CAPTURE_FUNCTIONS;
_ZCACHE_CAPTURE_FUNCTIONS=(antigen-bundle -antigen-load-env -antigen-load-source antigen-apply)
-antigen-cache-init () {
  # Capture functions
  --cache-capture () {
    local f; for f in $_ZCACHE_CAPTURE_FUNCTIONS; do
      eval "function ${_ZCACHE_CAPTURE_PREFIX}$(functions -- ${f})"
    done
  }

  # Release previously captured functions
  --cache-release-function () {
    local f=$1
    eval "function $(functions -- ${_ZCACHE_CAPTURE_PREFIX}${f} | sed s/${_ZCACHE_CAPTURE_PREFIX}//)"
    unfunction -- ${_ZCACHE_CAPTURE_PREFIX}${f} &> /dev/null
  }

  --cache-release () {
    local f; for f in $_ZCACHE_CAPTURE_FUNCTIONS; do
      --cache-release-function $f
    done
  }
  
  --cache-capture
  antigen-apply () {
    # Release function to apply
    --cache-release-function antigen-bundle
    local bundle
    for bundle in "${_ZCACHE_CAPTURE_BUNDLE[@]}"; do
      antigen-bundle "${=bundle[@]}"
    done
    -zcache-generate-cache
    --cache-release
    [[ -f "$ANTIGEN_CACHE" ]] && source "$ANTIGEN_CACHE";
  }
  
  antigen-bundle () {
    _ZCACHE_CAPTURE_BUNDLE+=("${(j: :)${(q)@}}")
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
