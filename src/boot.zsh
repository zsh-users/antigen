# Antigen: A simple plugin manager for zsh
# Authors: Shrikant Sharat Kandula
#          and Contributors <https://github.com/zsh-users/antigen/contributors>
# Homepage: http://antigen.sharats.me
# License: MIT License <mitl.sharats.me>

ANTIGEN_CACHE="${ANTIGEN_CACHE:-${ADOTDIR:-$HOME/.antigen}/init.zsh}"

for config in $ANTIGEN_CHECK_FILES; do
  if [[ "$config" -nt "$config.zwc" ]]; then
    { zcompile "$config" } &!
    [[ -f "$ANTIGEN_CACHE" ]] && rm -f "$ANTIGEN_CACHE"
  fi
done

[[ -f $ANTIGEN_CACHE && ! $_ANTIGEN_CACHE_LOADED == true ]] && source "$ANTIGEN_CACHE" && return 0;
