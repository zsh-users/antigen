# Used to fastboot antigen
_ZCACHE_PAYLOAD="${ADOTDIR:-$HOME/.antigen}/.cache/.zcache-payload"
[[ -f $_ZCACHE_PAYLOAD && ! $_ZCACHE_CACHE_LOADED == true ]] && source "$_ZCACHE_PAYLOAD" && return;

autoload -U is-at-least;
if is-at-least 4.3.7; then
  _ANTIGEN_INSTALL_DIR=${0:A:h}
else
  _ANTIGEN_INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
fi
source $_ANTIGEN_INSTALL_DIR/bin/antigen.zsh

