zmodload zsh/parameter

if [[ $ANTIGEN_CACHE != false ]]; then
  ANTIGEN_CACHE="${ANTIGEN_CACHE:-${ADOTDIR:-$HOME/.antigen}/init.zsh}"
  ANTIGEN_RSRC="${ADOTDIR:-$HOME/.antigen}/.resources"

  if [[ $ANTIGEN_AUTO_CONFIG != false && -f $ANTIGEN_RSRC ]]; then
    ANTIGEN_CHECK_FILES=$(cat $ANTIGEN_RSRC 2> /dev/null)
    ANTIGEN_CHECK_FILES=(${(@f)ANTIGEN_CHECK_FILES})

    for config in $ANTIGEN_CHECK_FILES; do
      if [[ "$config" -nt "$config.zwc" ]]; then
        { zcompile "$config" } &!
        [[ -f "$ANTIGEN_CACHE" ]] && rm -f "$ANTIGEN_CACHE"
      fi
    done
  fi

  [[ -f $ANTIGEN_CACHE && ! $_ANTIGEN_CACHE_LOADED == true ]] && source "$ANTIGEN_CACHE" && return 0;
fi
