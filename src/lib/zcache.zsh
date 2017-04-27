ANTIGEN_CACHE="${ANTIGEN_CACHE:-$ADOTDIR/init.zsh}"

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
  local bundle _payload _sources line themes

  for bundle in $_ANTIGEN_BUNDLE_RECORD; do
    # Extract bundle metadata to pass them to -antigen-parse-bundle function.
    # TODO -antigen-parse-bundle should be refactored for next major to
    # support multiple positional arguments.
    bundle=(${(@s/ /)bundle})

    local url=$bundle[1]
    local loc=$bundle[2]
    local btype=$bundle[3]
    local make_local_clone=$bundle[4]

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
-antigen-cache-init () {
  eval "function --$(functions -- antigen-apply)"
  antigen-apply () {
    -zcache-generate-cache
    [[ -f "$ANTIGEN_CACHE" ]] && source "$ANTIGEN_CACHE";
  }

  # Defer cloning.
  eval "function --$(functions -- antigen-bundle-install)"
  -antigen-bundle-install () {}

  # Defer loading.
  eval "function --$(functions -- antigen-load)"
  -antigen-load () {}
}
