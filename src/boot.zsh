zmodload zsh/parameter
autoload -U is-at-least

# While boot.zsh is part of the ext/cache functionallity it may be disabled
# with ANTIGEN_CACHE flag, and it's always compiled with antigen.zsh
if [[ $ANTIGEN_CACHE != false ]]; then
  ANTIGEN_CACHE="${ANTIGEN_CACHE:-${ADOTDIR:-$HOME/.antigen}/init.zsh}"
  ANTIGEN_RSRC="${ANTIGEN_RSRC:-${ADOTDIR:-$HOME/.antigen}/.resources}"

  # It may not be necessary to check ANTIGEN_AUTO_CONFIG.
  if [[ $ANTIGEN_AUTO_CONFIG != false && -f $ANTIGEN_RSRC ]]; then
    # Check the list of files for configuration changes (uses -nt comp)
    ANTIGEN_CHECK_FILES=$(cat $ANTIGEN_RSRC 2> /dev/null)
    ANTIGEN_CHECK_FILES=(${(@f)ANTIGEN_CHECK_FILES})

    for config in $ANTIGEN_CHECK_FILES; do
      if [[ "$config" -nt "$config.zwc" ]]; then
        # Flag configuration file as newer
        { zcompile "$config" } &!
        # Kill cache file in order to force full loading (see a few lines below)
        [[ -f "$ANTIGEN_CACHE" ]] && rm -f "$ANTIGEN_CACHE"
      fi
    done
  fi

  # If there is a cache file do load from it
  if [[ -f $ANTIGEN_CACHE && ! $_ANTIGEN_CACHE_LOADED == true ]]; then
    # Wrap antigen in order to defer cache source until `antigen-apply`
    antigen() {
      if [[ $1 == "apply" ]]; then
        source "$ANTIGEN_CACHE"
      # Handle `antigen-init` command properly
      elif [[ $1 == "init" ]]; then
        source "$2"
      fi
    }
    # Do not continue loading antigen as cache bundle takes care of it.
    return 0
  fi
fi
