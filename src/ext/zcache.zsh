_ANTIGEN_CACHE="${_ANTIGEN_CACHE:-$ADOTDIR/init.zsh}"
# Whether to use bundle or reference cache (since v1.4.0)
_ZCACHE_BUNDLE=${_ZCACHE_BUNDLE:-false}

# Removes cache payload and metadata if available
#
# Usage
#   zcache-cache-reset
#
# Returns
#   Nothing
antigen-reset () {
  [[ -f "$_ANTIGEN_CACHE" ]] && rm -f "$_ANTIGEN_CACHE"
  echo 'Done. Please open a new shell to see the changes.'
}

# Antigen command to load antigen configuration
#
# This method is slighlty more performing than using various antigen-* methods.
#
# Usage
#   Referencing an antigen configuration file:
#
#       antigen-init "/path/to/antigenrc"
#
#   or using HEREDOCS:
#
#       antigen-init <<EOBUNDLES
#           antigen use oh-my-zsh
#
#           antigen bundle zsh/bundle
#           antigen bundle zsh/example
#
#           antigen theme zsh/theme
#
#           antigen apply
#       EOBUNDLES
#
# Returns
#   Nothing
antigen-init () {
  local src="$1"

  # If we're given an argument it should be a path to a file
  if [[ -n "$src" ]]; then
    if [[ -f "$src" ]]; then
      source "$src"
      return
    else
      echo "Antigen: invalid argument provided.";
      return 1
    fi
  fi

  # Otherwise we expect it to be a heredoc
  grep '^[[:space:]]*[^[:space:]#]' | while read -r line; do
    eval $line
  done
}

# Clears $0 and ${0} references from cached sources.
#
# This is needed otherwise plugins trying to source from a different path
# will break as those are now located at $_ANTIGEN_CACHE
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
# Result is stored in _ANTIGEN_CACHE. Loaded bundles and metadata is stored
# in _ZCACHE_META_PATH.
#
# _ANTIGEN_BUNDLE_RECORD and fpath is stored in cache.
#
# Usage
#   -zcache-generate-cache
#
# Returns
#   Nothing. Generates _ANTIGEN_CACHE
-zcache-generate-cache () {
  local -aU _extensions_paths
  local -aU _binary_paths
  local -a _bundles_meta
  local _payload=""
  local _sources=""
  local location=""
  for bundle in ${(@f)_ANTIGEN_BUNDLE_RECORD}; do
    # -antigen-load-list "$url" "$loc" "$make_local_clone"
    eval "$(-antigen-parse-bundle ${=bundle})"
    _bundles_meta+=("$url $loc $btype $make_local_clone $branch")

    if $make_local_clone; then
      -antigen-ensure-repo "$url"
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
        _binary_paths+=($line)
      fi
    done

    if $make_local_clone; then
      location="$(-antigen-get-clone-dir "$url")/$loc"
    else
      location="$url/"
    fi

    if [[ -d "$location" ]]; then
      _extensions_paths+=($location)
    fi

    if [[ -d "$location/functions" ]]; then
      _extensions_paths+=($location/functions)
    fi
  done

  _payload="#-- START ZCACHE GENERATED FILE
#-- GENERATED: $(date)
#-- ANTIGEN {{ANTIGEN_VERSION}}
$(functions -- _antigen)
antigen () { [[ \"\$ZSH_EVAL_CONTEXT\" =~ \"toplevel:*\" ]] && source \""$_ANTIGEN_INSTALL_DIR/antigen.zsh"\" && eval antigen \$@}
fpath+=(${_extensions_paths[@]}); PATH=\"\$PATH:${_binary_paths[@]}\"
autoload -Uz compinit && compinit -C -d $_ANTIGEN_COMPDUMP
compdef antigen _antigen\NL"
  _payload+=$_sources
  # \NL (\n) prefix is for backward compatibility
  _payload+="_ANTIGEN_BUNDLE_RECORD=\"\NL${(j:\NL:)_bundles_meta}\"
  _ANTIGEN_CACHE_LOADED=true _ANTIGEN_CACHE_VERSION={{ANTIGEN_VERSION}}\NL"

  # Cache omz/prezto env variables. See https://github.com/zsh-users/antigen/pull/387
  if [[ ! -z "$ZSH" ]]; then
    _payload+="ZSH=\"$ZSH\" ZSH_CACHE_DIR=\"$ZSH_CACHE_DIR\"\NL";
  fi
  if [[ ! -z "$ZDOTDIR" ]]; then
    _payload+="ZDOTDIR=\"$ADOTDIR/repos/\"\NL";
  fi
  _payload+="#-- END ZCACHE GENERATED FILE\NL"

  echo -E $_payload | sed 's/\\NL/\'$'\n/g' >! "$_ANTIGEN_CACHE"
  zcompile "$_ANTIGEN_CACHE"
}
