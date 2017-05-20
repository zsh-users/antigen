ANTIGEN_CACHE="${ANTIGEN_CACHE:-$ADOTDIR/init.zsh}"
# Whether to use bundle or reference cache (since v1.4.0)
_ZCACHE_BUNDLE=${_ZCACHE_BUNDLE:-false}

# Clears $0 and ${0} references from cached sources.
#
# This is needed otherwise plugins trying to source from a different path
# will break as those are now located at $ANTIGEN_CACHE
#
# This does avoid function-context $0 references.
#
# This does handles the following patterns:
#   $0
#   ${0}
#   ${funcsourcetrace[1]%:*}
#   ${(%):-%N}
#   ${(%):-%x}
#
# Usage
#   -zcache-process-source "/path/to/source" ["theme"|"plugin"]
#
# Returns
#   Returns the cached sources without $0 and ${0} references
-zcache-process-source () {
  local src="$1"
  local btype="$2"

  # Removes $0 references globally (exclusively)
  local globals_only='/\{$/,/^\}/!{
    /\$.?0/i\'$'\n''__ZCACHE_FILE_PATH="'$src'"
    s/\$(.?)0(.?)/\$\1__ZCACHE_FILE_PATH\2/
  }'

  # Removes funcsourcetrace, and ${%} references globally
  local globals='/.*/{
    /\$.?(funcsourcetrace\[1\]\%\:\*|\(\%\)\:\-\%(N|x))/i\'$'\n''__ZCACHE_FILE_PATH="'$src'"
    s/\$(.?)(funcsourcetrace\[1\]\%\:\*|\(\%\)\:\-\%(N|x))(.?)/\$\1__ZCACHE_FILE_PATH\4/
  }'

  # Removes `local` from temes globally
  local sed_regexp_themes=''
  if [[ "$btype" == "theme" ]]; then
    themes='/\{$/,/^\}/!{
      s/^local //
    }'
    sed_regexp_themes="-e "$themes
  fi

  cat "$src" | sed -E -e $globals -e $globals_only $sed_regexp_themes
}

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
  local bundle _payload _sources

  for bundle in $_ANTIGEN_BUNDLE_RECORD; do
    # Extract bundle metadata to pass them to -antigen-parse-bundle function.
    # TODO -antigen-parse-bundle should be refactored for next major to
    # support multiple positional arguments.
    bundle=(${(@s/ /)bundle})
    local no_local_clone=""
    [[ $bundle[4] == "false" ]] && no_local_clone="--no-local-clone"
    eval "$(-antigen-parse-bundle $bundle[1] $bundle[2] --btype=$bundle[3] $no_local_clone)"

    local location="$url"
    if $make_local_clone; then
      location="$(-antigen-get-clone-dir "$url")"
    fi

    if [[ $loc != "/" ]]; then
      location="$location/$loc"
    fi

    if [[ -d "$location" ]]; then
      _fpath+=($location)
    fi

    if [[ -d "$location/functions" ]]; then
      _fpath+=($location/functions)
    fi

    -antigen-load-list "$url" "$loc" "$make_local_clone" | while read line; do
      if [[ -f "$line" ]]; then
        # Whether to use bundle or reference cache
        # Force bundle cache for btype = theme, until PR
        # https://github.com/robbyrussell/oh-my-zsh/pull/3743 is merged.
        if [[ $_ZCACHE_BUNDLE == true || $btype == "theme" ]]; then
          _sources+="#-- SOURCE: $line\NL"
          _sources+=$(-zcache-process-source "$line" "$btype")
          _sources+="\NL;#-- END SOURCE\NL"
        else
          _sources+="source \"$line\";\NL"
        fi
      elif [[ -d "$line" ]]; then
        _PATH+=($line)
      fi
    done
  done

  _payload="#-- START ZCACHE GENERATED FILE
#-- GENERATED: $(date)
#-- ANTIGEN {{ANTIGEN_VERSION}}
$(functions -- _antigen)
antigen () {
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

  _payload+="typeset -aU _ANTIGEN_BUNDLE_RECORD;\
      _ANTIGEN_BUNDLE_RECORD=("$(print ${(qq)_ANTIGEN_BUNDLE_RECORD})")\NL"
  _payload+="_ANTIGEN_CACHE_LOADED=true ANTIGEN_CACHE_VERSION='{{ANTIGEN_VERSION}}'\NL"

  _payload+="#-- END ZCACHE GENERATED FILE\NL"

  echo -E $_payload | sed 's/\\NL/\'$'\n/g' >! "$ANTIGEN_CACHE"
  { zcompile "$ANTIGEN_CACHE" } &!

  # Compile config files, if any
  [[ -n $ANTIGEN_CHECK_FILES ]] && { zcompile "$ANTIGEN_CHECK_FILES" } &!

  return true
}
