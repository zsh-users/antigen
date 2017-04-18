# Antigen: A simple plugin manager for zsh
# Authors: Shrikant Sharat Kandula
#          and Contributors <https://github.com/zsh-users/antigen/contributors>
# Homepage: http://antigen.sharats.me
# License: MIT License <mitl.sharats.me>
zmodload zsh/parameter

ANTIGEN_CACHE="${ANTIGEN_CACHE:-${ADOTDIR:-$HOME/.antigen}/init.zsh}"
ANTIGEN_RSRC="${ADOTDIR:-$HOME/.antigen}/.resources"

if [[ $ANTIGEN_AUTO_CONFIG == true && -f $ANTIGEN_RSRC ]]; then
  ANTIGEN_CHECK_FILES=$(cat $ANTIGEN_RSRC 2> /dev/null)
  ANTIGEN_CHECK_FILES=(${(@f)ANTIGEN_CHECK_FILES})
fi

for config in $ANTIGEN_CHECK_FILES; do
  if [[ "$config" -nt "$config.zwc" ]]; then
    { zcompile "$config" } &!
    [[ -f "$ANTIGEN_CACHE" ]] && rm -f "$ANTIGEN_CACHE"
  fi
done

[[ -f $ANTIGEN_CACHE && ! $_ANTIGEN_CACHE_LOADED == true ]] && source "$ANTIGEN_CACHE" && return;
