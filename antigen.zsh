# Used to fastboot antigen
_ANTIGEN_CACHE="${_ANTIGEN_CACHE:-${ADOTDIR:-$HOME/.antigen}/init.zsh}"
[[ -f $_ANTIGEN_CACHE && ! $_ANTIGEN_CACHE_LOADED == true ]] && source "$_ANTIGEN_CACHE" && return;
_ANTIGEN_INSTALL_DIR=${0:A:h}
source $_ANTIGEN_INSTALL_DIR/bin/antigen.zsh
