# Antigen: A simple plugin manager for zsh
# Authors: Shrikant Sharat Kandula
#          and Contributors <https://github.com/zsh-users/antigen/contributors>
# Homepage: http://antigen.sharats.me
# License: MIT License <mitl.sharats.me>

_ANTIGEN_CACHE="${_ANTIGEN_CACHE:-${ADOTDIR:-$HOME/.antigen}/init.zsh}"

for config in $_ANTIGEN_CHECK_FILES; do
  if [[ "$config" -nt "$config.zwc" ]]; then
    zcompile "$config"
    [[ -f "$_ANTIGEN_CACHE" ]] && \rm -f "$_ANTIGEN_CACHE"
  fi
done

[[ -f $_ANTIGEN_CACHE && ! $_ANTIGEN_CACHE_LOADED == true ]] && source "$_ANTIGEN_CACHE" && return;
