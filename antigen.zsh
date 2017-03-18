# Used to fastboot antigen
_ZCACHE_PAYLOAD="${ADOTDIR:-$HOME/.antigen}/init.zsh"
[[ -f $_ZCACHE_PAYLOAD && ! $_ZCACHE_CACHE_LOADED == true ]] && source "$_ZCACHE_PAYLOAD" && return;
_ANTIGEN_INSTALL_DIR=${0:A:h}
source $_ANTIGEN_INSTALL_DIR/bin/antigen.zsh
