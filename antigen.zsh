autoload -U is-at-least;
if is-at-least 4.3.7; then
  _ANTIGEN_INSTALL_DIR=${0:A:h}
else
  _ANTIGEN_INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
fi
source $_ANTIGEN_INSTALL_DIR/bin/antigen.zsh

